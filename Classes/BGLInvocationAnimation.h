//
//  BGLInvocationAnimation.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/28/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLAnimation.h"


@interface BGLInvocationAnimation : BGLAnimation {
    NSInvocation *invocation;
}
+ (BGLInvocationAnimation *)animationWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anObject;
- (id)initWithInvocation:(NSInvocation *)anInvocation;
@end
