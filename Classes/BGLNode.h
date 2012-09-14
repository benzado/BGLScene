//
//  BGLNode.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/8/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLMatrix.h"


@class BGLScene;
@class BGLProgram;
@class BGLRenderState;
@class BGLAnimation;


@interface BGLNode : NSObject {
    BGLScene *scene;
    BGLProgram *program;
    BGLNode *supernode;
    NSMutableArray *subnodes;
    NSMutableArray *pendingSubnodes;
    BOOL isAnimating;
    NSMutableArray *animations;
    BGLMatrix modelViewMatrix;
    BOOL hidden;
    BOOL paused;
    int tag;
}
@property (nonatomic,readonly) BGLScene *scene;
@property (nonatomic,retain) BGLProgram *program;
@property (nonatomic,readonly) BGLNode *supernode;
@property (nonatomic,readonly) NSArray *subnodes;
@property (nonatomic,getter=isHidden) BOOL hidden;
@property (nonatomic,getter=isPaused) BOOL paused;
@property (nonatomic) int tag;
@property (nonatomic) BGLVector3 position;
// Nodes
- (void)addSubnode:(BGLNode *)node;
- (void)removeFromSupernode;
- (void)removeAllSubnodes;
- (id)nodeWithTag:(int)searchTag;
// Animations
- (void)addAnimation:(BGLAnimation *)animation;
// ModelView Matrix
- (void)resetModelViewMatrix;
- (void)setModelViewMatrix:(BGLMatrix)matrix;
- (void)translateBy:(BGLVector3)vector;
- (void)scaleBy:(BGLVector3)vector;
- (void)rotateBy:(float)degrees about:(BGLVector3)vector;
// Misc
- (BGLNode *)hitTest:(BGLVector3)p0;
- (BGLVector3)transformPointFromRoot:(BGLVector3)p0;
// Abstract (for subclasses to override)
- (BOOL)containsPoint:(BGLVector3)p;
- (void)prepareRenderState:(BGLRenderState *)state;
- (void)render;
- (void)restoreRenderState:(BGLRenderState *)state;
@end


@interface BGLNode (Private)
- (void)didAddToScene:(BGLScene *)aScene;
- (void)renderSelfAndSubnodesWithState:(BGLRenderState *)state;
- (void)animateWithElapsedTime:(CFTimeInterval)t;
@end
