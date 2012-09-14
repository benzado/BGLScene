//
//  BGLScene.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/16/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Touchable.h"
#import "ESRenderer.h"
#import "BGLAnimation.h"
#import "BGLUtilities.h"

@class BGLNode;

@interface BGLScene : NSObject {
    BGLNode *rootNode;
    CGSize viewportSize;
    CFTimeInterval previousFrameTime;
}
@property (nonatomic,retain) BGLNode *rootNode;
- (void)updateViewportSize:(CGSize)size;
- (void)renderWithRenderer:(id <ESRenderer>)renderer;
- (void)syncAnimationClock; // must be called before starting animations
- (void)performAnimations;
- (void)animateWithElapsedTime:(CFTimeInterval)t;
- (id <Touchable>)touchableForPoint:(CGPoint)p;
@end
