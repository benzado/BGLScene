//
//  BGLAnimationGroup.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/28/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BGLAnimation.h"

/*
 1. Groups last only as long as the shortest animation within.
 2. Contained animations' nextAnimation properties are discarded.
 */

@interface BGLAnimationGroup : BGLAnimation {
    NSArray *animationArray;
}
+ (BGLAnimationGroup *)groupWithAnimations:(NSArray *)array;
- (id)initWithAnimations:(NSArray *)array;
@end
