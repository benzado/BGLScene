//
//  BGLPolygon.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/7/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLNode.h"
#import "BGLUtilities.h"
#import "BGLMatrix.h"


typedef struct {
    BGLVector2 position;
    BGLColor color;
} BGLPolygonVertex;


@interface BGLPolygon : BGLNode {
    NSMutableData *vertexData;
    BGLPolygonVertex nextVertex;
    GLenum mode;
}
+ (BGLPolygon *)polygonWithRect:(CGRect)rect color:(BGLColor)color;
+ (BGLPolygon *)polygonWithRect:(CGRect)rect topColor:(BGLColor)topColor bottomColor:(BGLColor)bottomColor;
@property (nonatomic) GLenum mode;
- (void)setColor:(BGLColor)color;
- (void)addVertexAtPosition:(BGLVector2)position;
@end
