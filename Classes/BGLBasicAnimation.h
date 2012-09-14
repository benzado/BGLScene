//
//  BGLBasicAnimation.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/24/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLAnimation.h"
#import "BGLMatrix.h"
#import "BGLUtilities.h"


typedef void (* BGLSetFunc1)(id, SEL, float);
typedef void (* BGLSetFunc2)(id, SEL, BGLVector2);
typedef void (* BGLSetFunc3)(id, SEL, BGLVector3);
typedef void (* BGLSetFunc4)(id, SEL, BGLColor);


typedef float (* BGLScalarCurveFunc)(float);


extern float BGLScalarCurveLinear(float);
extern float BGLScalarCurveEaseInEaseOut(float);
extern float BGLScalarCurveEaseIn(float);
extern float BGLScalarCurveEaseOut(float);
extern float BGLScalarCurvePulse(float);
extern float BGLScalarCurveSaw(float);


static const int kBGLScalarRepeatForever = NSUIntegerMax;


@interface BGLBasicAnimation : BGLAnimation {
    id target;
    SEL setSelector;
    union {
        BGLSetFunc1 v1;
        BGLSetFunc2 v2;
        BGLSetFunc3 v3;
        BGLSetFunc4 v4;
    } setFunc;
    union {
        float v[4];
        float v1;
        BGLVector2 v2;
        BGLVector3 v3;
        BGLColor v4;
    } initial, final;
    unsigned int valueCount;
    BGLScalarCurveFunc curveFunc;
    float duration;
    unsigned int repeatCount;
    float clock;
}
+ (BGLBasicAnimation *)animationWithTarget:(NSObject *)target selector:(SEL)setSelector;
@property (nonatomic) float duration;
@property (nonatomic) unsigned int repeatCount;
@property (nonatomic) BGLScalarCurveFunc curveFunc;
@property (nonatomic) float initialScalar;
@property (nonatomic) float finalScalar;
@property (nonatomic) BGLVector2 initialVector2;
@property (nonatomic) BGLVector2 finalVector2;
@property (nonatomic) BGLVector3 initialVector3;
@property (nonatomic) BGLVector3 finalVector3;
@property (nonatomic) BGLColor initialColor;
@property (nonatomic) BGLColor finalColor;
@end
