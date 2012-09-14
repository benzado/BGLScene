//
//  BGLRenderState.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/9/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLMatrix.h"


@interface BGLRenderState : NSObject {
    BGLMatrix modelViewMatrix;
    NSMutableData *matrixStack;
}
- (NSUInteger)stackSize;
- (void)pushModelViewMatrix;
- (void)popModelViewMatrix;
- (void)getModelViewMatrix:(BGLMatrix)matrix;
- (void)setModelViewMatrix:(BGLMatrix)matrix;
- (void)premultiplyModelViewMatrixBy:(BGLMatrix)matrix;
- (void)multiplyModelViewMatrixBy:(BGLMatrix)matrix;
- (void)translateBy:(BGLVector3)vector;
- (void)scaleBy:(BGLVector3)vector;
- (void)rotateBy:(float)degrees about:(BGLVector3)vector;
@end
