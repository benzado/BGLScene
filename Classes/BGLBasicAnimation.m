//
//  BGLBasicAnimation.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/24/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLBasicAnimation.h"


// Curve function domain and range is [0,1]


float BGLScalarCurveLinear(float t)
{
    // follows a straight line from <0,0> to <1,1>
    return t;
}


float BGLScalarCurveEaseInEaseOut(float t)
{
    // follows a sine wave from trough to peak
    return 0.5f * (1.0f - cosf(t * M_PI));
}


float BGLScalarCurveEaseIn(float t)
{
    // follows a sine wave from trough to center (slow at first, then faster)
    return 1.0f - cosf(t * M_PI_2);
}


float BGLScalarCurveEaseOut(float t)
{
    // follows a sine wave from center to peak (fast at first, then slower)
    return sinf(t * M_PI_2);
}


float BGLScalarCurvePulse(float t)
{
    // follows a sine wave from trough to peak to trough (ends where it started)
    return 0.5f * (1.0f - cosf(t * 2*M_PI));
}


float BGLScalarCurveSaw(float t)
{
    // follows a jigsaw: <0,0> to <0.5,1> to <1,0>
    return 0.5f - fabsf(0.5f - t);
}


@interface BGLBasicAnimation ()
- (id)initWithTarget:(NSObject *)aTarget selector:(SEL)aSel;
@end



@implementation BGLBasicAnimation


@synthesize duration;
@synthesize repeatCount;
@synthesize curveFunc;


+ (BGLBasicAnimation *)animationWithTarget:(NSObject *)target selector:(SEL)setSelector
{
    return [[[self alloc] initWithTarget:target selector:setSelector] autorelease];
}


- (id)initWithTarget:(NSObject *)aTarget selector:(SEL)aSel
{
    if ((self = [super init])) {
        target = aTarget;
        setSelector = aSel;

        NSMethodSignature *sig = [target methodSignatureForSelector:setSelector];
        NSAssert([sig numberOfArguments] == 3, @"selector must take argument");
        const char *t = [sig getArgumentTypeAtIndex:2];
        
        if (strcmp(t, @encode(float)) == 0) {
            valueCount = 1;
        } else if (strcmp(t, @encode(BGLVector2)) == 0) {
            valueCount = 2;
        } else if (strcmp(t, @encode(BGLVector3)) == 0) {
            valueCount = 3;
        } else if (strcmp(t, @encode(BGLColor)) == 0) {
            valueCount = 4;
        } else {
            ALog(@"Can't handle argument type: %s", t);
        }
                 
        setFunc.v1 = (BGLSetFunc1)[target methodForSelector:setSelector];
        curveFunc = &BGLScalarCurveEaseInEaseOut;
        duration = 0.3f;
        repeatCount = 1;
    }
    return self;
}


- (float)initialScalar { return initial.v1; }
- (BGLVector2)initialVector2 { return initial.v2; }
- (BGLVector3)initialVector3 { return initial.v3; }
- (BGLColor)initialColor { return initial.v4; }

- (float)finalScalar { return final.v1; }
- (BGLVector2)finalVector2 { return final.v2; }
- (BGLVector3)finalVector3 { return final.v3; }
- (BGLColor)finalColor { return final.v4; }

- (void)setInitialScalar:(float)i { initial.v1 = i; }
- (void)setInitialVector2:(BGLVector2)i { initial.v2 = i; }
- (void)setInitialVector3:(BGLVector3)i { initial.v3 = i; }
- (void)setInitialColor:(BGLColor)i { initial.v4 = i; }

- (void)setFinalScalar:(float)f { final.v1 = f; }
- (void)setFinalVector2:(BGLVector2)f { final.v2 = f; }
- (void)setFinalVector3:(BGLVector3)f { final.v3 = f; }
- (void)setFinalColor:(BGLColor)f { final.v4 = f; }


#pragma mark BGLAnimation


- (BOOL)animateWithElapsedTime:(float)timeSinceLastFrame
{
    float t = clock + timeSinceLastFrame;
    if (t > duration) {
        if (repeatCount <= 1) {
            if (curveFunc(1) < 0.5f) {
                switch (valueCount) {
                    case 1: setFunc.v1(target, setSelector, initial.v1); return NO;
                    case 2: setFunc.v2(target, setSelector, initial.v2); return NO;
                    case 3: setFunc.v3(target, setSelector, initial.v3); return NO;
                    case 4: setFunc.v4(target, setSelector, initial.v4); return NO;
                }
            } else {
                switch (valueCount) {
                    case 1: setFunc.v1(target, setSelector, final.v1); return NO;
                    case 2: setFunc.v2(target, setSelector, final.v2); return NO;
                    case 3: setFunc.v3(target, setSelector, final.v3); return NO;
                    case 4: setFunc.v4(target, setSelector, final.v4); return NO;
                }
            }
            return NO;
        }
        repeatCount -= 1;
        t = duration;
        clock = 0;
    } else {
        clock = t;
    }
    
    union {
        float v[4];
        float v1;
        BGLVector2 v2;
        BGLVector3 v3;
        BGLColor v4;
    } value;
    
    float n = curveFunc(t / duration);
#ifdef __ARM_NEON__
    /*
     q0        d0-d1    initial values
     q1        d2-d3    final values
     q2        d4-d5    scratch
     q3        d6-d7    scratch
     */
    __asm__ volatile
    (
     // Load register contents (q0=initial, final)
//     "vld1.32 {d0-d1}, [%1]        \n\t" // load four initial values into q0
//     "vld1.32 {d2-d3}, [%2]        \n\t" // load four final values into q1
     // Load in one step, since initial and final are contiguous:
     "vld1.32 {d0-d3}, [%1]        \n\t" // load initial into q0, final into q1
     // q0 := q1 + (q2 - q1) * n
     "vsub.f32 q2, q1, q0        \n\t" // q2 := q2 - q1
     "vmov s12, %3                \n\t"
     "vmla.f32 q0, q2, d6[0]    \n\t" // q0 := q0 + (q2 * %3)
     // Store result
     "vst1.f32 {d0-d1}, [%0]    \n\t" // store four computed values
     // Compiler Hint: output registers
     :
     // Compiler Hint: input registers
     : "r"(value.v), "r"(initial.v), "r"(final.v), "r"(n)
     // Compiler Hint: clobbered registers
     : "q0", "q1", "q2", "q3"
    );
#else    
    value.v[0] = initial.v[0] + (final.v[0] - initial.v[0]) * n;
    value.v[1] = initial.v[1] + (final.v[1] - initial.v[1]) * n;
    value.v[2] = initial.v[2] + (final.v[2] - initial.v[2]) * n;
    value.v[3] = initial.v[3] + (final.v[3] - initial.v[3]) * n;
#endif
    
    switch (valueCount) {
        case 1: setFunc.v1(target, setSelector, value.v1); return YES;
        case 2: setFunc.v2(target, setSelector, value.v2); return YES;
        case 3: setFunc.v3(target, setSelector, value.v3); return YES;
        case 4: setFunc.v4(target, setSelector, value.v4); return YES;
    }
    return YES;
}


@end
