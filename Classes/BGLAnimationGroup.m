//
//  BGLAnimationGroup.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/28/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLAnimationGroup.h"


@implementation BGLAnimationGroup

+ (BGLAnimationGroup *)groupWithAnimations:(NSArray *)array
{
    return [[[BGLAnimationGroup alloc] initWithAnimations:array] autorelease];
}


- (id)initWithAnimations:(NSArray *)array
{
    if ((self = [super init])) {
        animationArray = [array copy];
    }
    return self;
}


- (void)dealloc
{
    [animationArray release];
    [super dealloc];
}


- (BOOL)animateWithElapsedTime:(float)timeSinceLastFrame
{
    BOOL result = YES;
    for (BGLAnimation *a in animationArray) {
        BOOL keep = [a animateWithElapsedTime:timeSinceLastFrame];
        result = result && keep;
    }
    return result;
}


@end
