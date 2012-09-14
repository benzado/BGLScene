//
//  BGLNode.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/8/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import "BGLNode.h"
#import "BGLProgram.h"
#import "BGLRenderState.h"
#import "BGLAnimation.h"


static const int kAnimationCountMax = 8;
static const int kNodeCountMax = 8;


@implementation BGLNode


@synthesize scene;
@synthesize program;
@synthesize supernode;
@synthesize subnodes;
@synthesize hidden;
@synthesize paused;
@synthesize tag;


- (id)init
{
    if ((self = [super init])) {
        [self resetModelViewMatrix];
    }
    return self;
}


- (void)dealloc
{
    supernode = nil;
    [subnodes release];
    [animations release];
    [program release];
    [super dealloc];
}


- (void)descriptionIntoString:(NSMutableString *)string withPrefix:(NSString *)prefix
{
    [string appendString:prefix];
    [string appendFormat:@"%@:%p (%d)\n", [self class], self, tag];
    NSString *subprefix = [prefix stringByAppendingString:@"  "];
    for (BGLNode *node in subnodes) {
        [node descriptionIntoString:string withPrefix:subprefix];
    }
}


- (NSString *)description
{
    NSMutableString *string = [NSMutableString string];
    [self descriptionIntoString:string withPrefix:@""];
    return string;
}


#pragma mark Nodes


- (id)mutableSubnodes
{
    if (isAnimating) {
        if (pendingSubnodes == nil) {
            pendingSubnodes = [subnodes mutableCopy];
        }
        return pendingSubnodes;
    } else {
        return subnodes;
    }
}


- (void)addSubnode:(BGLNode *)node
{
    if (subnodes == nil) {
        subnodes = [[NSMutableArray alloc] init];
    }
    node->supernode = self;
    [[self mutableSubnodes] addObject:node];
    [node didAddToScene:self.scene];
}


- (void)removeFromSupernode
{
    BGLNode *s = supernode;
    if (s) {
        [self didAddToScene:nil];
        supernode = nil;
        [[s mutableSubnodes] removeObject:self];
    }
}


- (void)removeAllSubnodes
{
    for (BGLNode *sub in subnodes) {
        [sub didAddToScene:nil];
        sub->supernode = nil;
    }
    [[self mutableSubnodes] removeAllObjects];
}


- (id)nodeWithTag:(int)searchTag
{
    if (tag == searchTag) return self;
    for (BGLNode *testNode in subnodes) {
        BGLNode *foundNode = [testNode nodeWithTag:searchTag];
        if (foundNode) return foundNode;
    }
    return nil;
}


#pragma mark Animations


- (void)addAnimation:(BGLAnimation *)animation
{
    if (animations == nil) {
        animations = [[NSMutableArray alloc] initWithCapacity:kAnimationCountMax];
    }
#if DEBUG
    else {
        NSAssert([animations count] < kAnimationCountMax, @"Too many animations added to node!");
    }
#endif
    [animations addObject:animation];
}


- (void)removeAnimation:(BGLAnimation *)animation
{
#if DEBUG
    NSAssert([animations containsObject:animation], @"Attempt to remove animation that isn't there.");
#endif
    [animations removeObject:animation];
}


- (void)animateWithElapsedTime:(CFTimeInterval)t
{
    if (paused) return;
    isAnimating = YES;
    if (animations) {
        NSRange ar = NSMakeRange(0, [animations count]);
        if (ar.length) {
            // Copy elements so that the array object may be modified in-loop.
            BGLAnimation *aa[kAnimationCountMax];
            [animations getObjects:aa range:ar];
            for (int i = 0; i < ar.length; i++) {
                BGLAnimation *a = aa[i];
                BOOL keep = [a animateWithElapsedTime:t];
                if (! keep) {
                    BGLAnimation *an = a.nextAnimation;
                    if (an) [self addAnimation:an];
                    [self removeAnimation:a];
                }
            }
        }
    }
    if (subnodes) {
        for (BGLNode *n in subnodes) {
            [n animateWithElapsedTime:t];
        }
        if (pendingSubnodes) {
            [subnodes release];
            subnodes = pendingSubnodes;
            pendingSubnodes = nil;
        }
    }
    isAnimating = NO;
}


#pragma mark ModelView Matrix


- (void)resetModelViewMatrix
{
    BGLMatrixLoadIdentity(modelViewMatrix);
}


- (void)setModelViewMatrix:(BGLMatrix)matrix
{
    BGLMatrixCopy(modelViewMatrix, matrix);
}


- (BGLVector3)position
{
    return BGLVector3Make(modelViewMatrix[kBGLMatrixOffsetTranslateX],
                          modelViewMatrix[kBGLMatrixOffsetTranslateY],
                          modelViewMatrix[kBGLMatrixOffsetTranslateZ]);
}


- (void)setPosition:(BGLVector3)vector
{
    modelViewMatrix[kBGLMatrixOffsetTranslateX] = vector.x;
    modelViewMatrix[kBGLMatrixOffsetTranslateY] = vector.y;
    modelViewMatrix[kBGLMatrixOffsetTranslateZ] = vector.z;
}


- (void)translateBy:(BGLVector3)vector
{
    BGLMatrixTranslate(modelViewMatrix, vector.x, vector.y, vector.z);
}


- (void)scaleBy:(BGLVector3)vector
{
    BGLMatrixScale(modelViewMatrix, vector.x, vector.y, vector.z);
}


- (void)rotateBy:(float)degrees about:(BGLVector3)vector
{
    BGLMatrixRotate(modelViewMatrix, degrees, vector.x, vector.y, vector.z);
}


#pragma mark Misc


- (BGLNode *)hitTest:(BGLVector3)p0
{
    BGLMatrix m;
    if (BGLMatrixInvert(m, modelViewMatrix)) {
        BGLVector3 p1 = BGLMatrixApplyTransform(m, p0);
        if ([self containsPoint:p1]) {
            return self;
        }
        for (BGLNode *node in subnodes) {
            BGLNode *n = [node hitTest:p1];
            if (n) return n;
        }
    }
    return nil;
}


- (BGLVector3)transformPointFromRoot:(BGLVector3)p0
{
    BGLVector3 p1;
    if (supernode) {
        p1 = [supernode transformPointFromRoot:p0];
    } else {
        p1 = p0;
    }
    BGLMatrix t;
    BGLMatrixInvert(t, modelViewMatrix);
    return BGLMatrixApplyTransform(t, p1);
}


#pragma mark Abstract


- (BOOL)containsPoint:(BGLVector3)p
{
    return NO;
}


- (void)prepareRenderState:(BGLRenderState *)state
{
    [state pushModelViewMatrix];
    [state multiplyModelViewMatrixBy:modelViewMatrix];
}


- (void)render
{
}


- (void)restoreRenderState:(BGLRenderState *)state
{
    [state popModelViewMatrix];
}


#pragma mark Private


- (void)didAddToScene:(BGLScene *)aScene
{
    scene = aScene;
    [subnodes makeObjectsPerformSelector:@selector(didAddToScene:) withObject:scene];
}


- (void)renderSelfAndSubnodesWithState:(BGLRenderState *)state
{
    if (hidden) return;
#if DEBUG
    NSUInteger size = [state stackSize];
#endif
    [program use];
    [self prepareRenderState:state];
    [program applyUniformsFromState:state];
    [self render];
    [subnodes makeObjectsPerformSelector:@selector(renderSelfAndSubnodesWithState:) 
                              withObject:state];
    [self restoreRenderState:state];
#if DEBUG
    NSAssert1(size == [state stackSize], @"Stack size mismatch: %d", [state stackSize] - size);
#endif
}


@end
