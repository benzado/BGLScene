//
//  Touchable.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/15/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol Touchable <NSObject>
- (void)touch:(UITouch *)touch beganAtPoint:(CGPoint)p;
- (void)touch:(UITouch *)touch movedToPoint:(CGPoint)p;
- (void)touchEnded:(UITouch *)touch;
- (void)touchCancelled:(UITouch *)touch;
@end
