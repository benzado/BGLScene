//
//  EAGLView.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "EAGLView.h"

#import "ES2Renderer.h"
#import "FPBStroke.h"
#import "BGLScene.h"
#import "Touchable.h"


@implementation EAGLView

@synthesize animating;
@synthesize scene;
@dynamic animationFrameInterval;


// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
        self.multipleTouchEnabled = YES;
        activeTouchables = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

        renderer = [[ES2Renderer alloc] init];

        if (!renderer) {
            [self release];
            return nil;
        }

        animating = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(applicationDidEnterBackground:) 
                       name:UIApplicationDidEnterBackgroundNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(applicationWillEnterForeground:) 
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];
    }

    return self;
}


- (void)drawView:(id)sender
{
#if DEBUG
    static int frameCount = 0;
    static CFTimeInterval animationTime = 0;
    static CFTimeInterval renderTime = 0;
    static CFAbsoluteTime reportTime = 0;
    CFAbsoluteTime t0, t1, t2;
    
    t0 = CACurrentMediaTime();
#endif

    [scene performAnimations];

#if DEBUG
    t1 = CACurrentMediaTime();
#endif

    [scene renderWithRenderer:renderer];

#if DEBUG
    t2 = CACurrentMediaTime();
    
    animationTime += (t1 - t0);
    renderTime += (t2 - t1);
    frameCount += 1;
    
    if (frameCount == 128) {
        if (reportTime > 0) {
            NSLog(@"FRAMERATE: %f fps", 128.0 / (t0 - reportTime));
        }
        NSLog(@"MEAN ANIMATION TIME: %f ms", animationTime / 128.0 * 1000.0);
        NSLog(@"MEAN RENDER TIME: %f ms", renderTime / 128.0 * 1000.0);
        frameCount = 0;
        animationTime = 0;
        renderTime = 0;
        reportTime = t0;
    }
#endif
}


- (void)layoutSubviews
{
    [renderer allocateBufferStorageForLayer:(CAEAGLLayer*)self.layer];
    [scene updateViewportSize:self.layer.bounds.size];
    [self drawView:nil];
}


- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}


- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}


- (void)startAnimation
{
    if (!animating)
    {
        [scene syncAnimationClock];

        // CADisplayLink is API new to iPhone SDK 3.1.
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink setFrameInterval:animationFrameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        animating = TRUE;
    }
}


- (void)stopAnimation
{
    if (animating)
    {
        [displayLink invalidate];
        displayLink = nil;
        animating = FALSE;
    }
}


- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [renderer deleteBuffers];
}


- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [renderer genBuffers];
    [renderer allocateBufferStorageForLayer:(CAEAGLLayer*)self.layer];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [activeTouchables release];
    [renderer release];
    [super dealloc];
}


#pragma mark Touch Events


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInView:self];
        id <Touchable> t = [scene touchableForPoint:p];
        if (t) {
            id key = [NSValue valueWithPointer:touch];
            [activeTouchables setObject:t forKey:key];
            [t touch:touch beganAtPoint:p];
        }
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        id key = [NSValue valueWithPointer:touch];
        id <Touchable> t = [activeTouchables objectForKey:key];
        if (t) {
            CGPoint p = [touch locationInView:self];
            [t touch:touch movedToPoint:p];
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        id key = [NSValue valueWithPointer:touch];
        id <Touchable> t = [activeTouchables objectForKey:key];
        if (t) {
            [t touchEnded:touch];
            [activeTouchables removeObjectForKey:key];
        }
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        id key = [NSValue valueWithPointer:touch];
        id <Touchable> t = [activeTouchables objectForKey:key];
        if (t) {
            [t touchCancelled:touch];
            [activeTouchables removeObjectForKey:key];
        }
    }
}


@end

