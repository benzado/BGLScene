//
//  EAGLView.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ESRenderer.h"


@class BGLScene;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
    id <ESRenderer> renderer;
    NSMutableDictionary *activeTouchables;
    
    BGLScene *scene;

    BOOL animating;
    NSInteger animationFrameInterval;
    id displayLink;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic,retain) BGLScene *scene;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@end
