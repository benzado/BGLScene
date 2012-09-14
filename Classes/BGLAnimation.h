//
//  BGLAnimation.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/28/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BGLAnimation : NSObject {
    BGLAnimation *nextAnimation;
}
@property (nonatomic,retain) BGLAnimation *nextAnimation;
- (BOOL)animateWithElapsedTime:(float)timeSinceLastFrame;
@end
