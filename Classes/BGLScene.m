//
//  BGLScene.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/16/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLScene.h"
#import "BGLButton.h"


@implementation BGLScene


@synthesize rootNode;


- (void)dealloc
{
    [rootNode release];
    [super dealloc];
}


- (void)updateViewportSize:(CGSize)size
{
}


- (void)renderWithRenderer:(id <ESRenderer>)renderer
{
    [renderer renderRootNode:rootNode];
}


- (void)syncAnimationClock
{
    previousFrameTime = CACurrentMediaTime();
}


- (void)performAnimations
{
    CFTimeInterval now = CACurrentMediaTime();
    float t = now - previousFrameTime;
#if DEBUG
    if (t > 1.f/20.f) t = 1.f/20.f;
#endif
    [self animateWithElapsedTime:t];
    previousFrameTime = now;
}


- (void)animateWithElapsedTime:(CFTimeInterval)t
{
    [rootNode animateWithElapsedTime:t];
}


- (id <Touchable>)touchableForPoint:(CGPoint)p
{
    BGLNode *node = [self.rootNode hitTest:BGLVector3Make(p.x, p.y, 0)];
    if ([node conformsToProtocol:@protocol(Touchable)]) {
        return (id <Touchable>)node;
    } else {
        return nil;
    }
}


@end
