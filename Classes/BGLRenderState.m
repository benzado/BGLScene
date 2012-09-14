//
//  BGLRenderState.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/9/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import "BGLRenderState.h"


@implementation BGLRenderState


- (id)init
{
    if ((self = [super init])) {
        BGLMatrixLoadIdentity(modelViewMatrix);
        matrixStack = [[NSMutableData alloc] init];
    }
    return self;
}


- (void)dealloc
{
    [matrixStack release];
    [super dealloc];
}


- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"<RenderState:"];
    for (int i = 0; i < 16; i++) {
        if (i % 4 == 0) {
            [desc appendString:@"\n\t"];
        }
        [desc appendFormat:@" %5.2f", modelViewMatrix[i]];
    }
    [desc appendString:@"\n>"];
    return desc;
}


- (NSUInteger)stackSize
{
    return [matrixStack length] / sizeof(BGLMatrix);
}


- (void)pushModelViewMatrix
{
    [matrixStack appendBytes:modelViewMatrix length:sizeof(BGLMatrix)];
}


- (void)popModelViewMatrix
{
    NSInteger offset = [matrixStack length] - sizeof(BGLMatrix);
    [matrixStack getBytes:modelViewMatrix range:NSMakeRange(offset, sizeof(BGLMatrix))];
    [matrixStack setLength:offset];
}


- (void)getModelViewMatrix:(BGLMatrix)matrix
{
    BGLMatrixCopy(matrix, modelViewMatrix);
}


- (void)setModelViewMatrix:(BGLMatrix)matrix
{
    BGLMatrixCopy(modelViewMatrix, matrix);
}


- (void)premultiplyModelViewMatrixBy:(BGLMatrix)matrix
{
    BGLMatrixMultiply(modelViewMatrix, modelViewMatrix, matrix);
}


- (void)multiplyModelViewMatrixBy:(BGLMatrix)matrix
{
    BGLMatrixMultiply(modelViewMatrix, matrix, modelViewMatrix);
}


- (void)translateBy:(BGLVector3)vector
{
    BGLMatrixTranslate(modelViewMatrix, vector.x, vector.y, vector.z);
}


- (void)scaleBy:(BGLVector3)vector
{
    BGLMatrixScale(modelViewMatrix, vector.x, vector.y, vector.z);
}


- (void)rotateBy:(float)degrees about:(BGLVector3)vector
{
    BGLMatrixRotate(modelViewMatrix, degrees, vector.x, vector.y, vector.z);
}


@end
