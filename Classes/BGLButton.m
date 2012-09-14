//
//  BGLButton.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/15/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//


#import "BGLButton.h"
#import "BGLProgram.h"
#import "BGLShader.h"
#import "BGLUtilities.h"
#import "BGLScene.h"
#import "BGLRenderState.h"

#import "BGLManifest.h"


@implementation BGLButton


@synthesize frame;
@synthesize color;
@synthesize target;
@synthesize touchDownAction;
@synthesize touchUpInsideAction;
@synthesize highlighted;
@synthesize enabled;


- (id)init
{
    if ((self = [super init])) {
        self.program = [BGLProgram programNamed:@"Button"];
        self.enabled = YES;
    }
    return self;
}


- (void)setFrame:(CGRect)rect
{
    frame = rect;
    
    const CGFloat minX = 0; const CGFloat maxX = CGRectGetWidth(rect);
    const CGFloat minY = 0; const CGFloat maxY = CGRectGetHeight(rect);
    
    vertexPositions[0] = minX; vertexPositions[1] = minY;
    vertexPositions[2] = maxX; vertexPositions[3] = minY;
    vertexPositions[4] = minX; vertexPositions[5] = maxY;
    vertexPositions[6] = maxX; vertexPositions[7] = maxY;
    
    [self resetModelViewMatrix];
    [self translateBy:BGLVector3Make(CGRectGetMinX(frame), CGRectGetMinY(frame), 0)];
}


#pragma mark BGLNode


- (BOOL)containsPoint:(BGLVector3)p
{
    if (p.x < 0) return NO;
    if (p.y < 0) return NO;
    if (p.x > CGRectGetWidth(frame)) return NO;
    if (p.y > CGRectGetHeight(frame)) return NO;
    return YES;
}


- (void)render
{
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);

    BGLUniformColor(SHU[shu_Button_color], highlighted ? &BGLColorWhite : &color);
    
    glVertexAttribPointer(sha_Button_vertexPosition, 2, GL_FLOAT, GL_FALSE, 0, vertexPositions);
    glEnableVertexAttribArray(sha_Button_vertexPosition);
    
    DAssert([self.program validate], @"Failed to validate program.");

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


#pragma mark Touchable


- (void)touch:(UITouch *)touch beganAtPoint:(CGPoint)p
{
    if (! enabled) return;
    highlighted = YES;
    if (touchDownAction) {
        [target performSelector:touchDownAction withObject:self];
    }
}


- (void)touch:(UITouch *)touch movedToPoint:(CGPoint)p0
{
    if (! enabled) return;
    BGLVector3 p1 = [self transformPointFromRoot:BGLVector3Make(p0.x, p0.y, 0)];
    highlighted = [self containsPoint:p1];
}


- (void)touchEnded:(UITouch *)touch
{
    if (! enabled) return;
    if (highlighted && touchUpInsideAction) {
        [target performSelector:touchUpInsideAction withObject:self];
    }
    highlighted = NO;    
}


- (void)touchCancelled:(UITouch *)touch
{
    // perform no action
    highlighted = NO;
}


@end
