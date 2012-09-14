//
//  BGLAnimation.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/28/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLAnimation.h"


@implementation BGLAnimation


@synthesize nextAnimation;


- (BOOL)animateWithElapsedTime:(float)timeSinceLastFrame
{
    return NO;
}


- (void)dealloc
{
    [nextAnimation release];
    [super dealloc];
}


@end
