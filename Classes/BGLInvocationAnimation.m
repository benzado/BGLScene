//
//  BGLInvocationAnimation.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/28/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLInvocationAnimation.h"


@implementation BGLInvocationAnimation


+ (BGLInvocationAnimation *)animationWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anObject
{
    NSMethodSignature *sig = [aTarget methodSignatureForSelector:aSelector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:aTarget];
    [inv setSelector:aSelector];
    if (anObject) {
        [inv setArgument:&anObject atIndex:2];
    }
    return [[[BGLInvocationAnimation alloc] initWithInvocation:inv] autorelease];
}


- (id)initWithInvocation:(NSInvocation *)anInvocation
{
    if ((self = [super init])) {
        invocation = [anInvocation retain];
        [invocation retainArguments];
    }
    return self;
}


- (BOOL)animateWithElapsedTime:(float)timeSinceLastFrame
{
    [invocation invoke];
    return NO;
}


- (void)dealloc
{
    [invocation release];
    [super dealloc];
}


@end
