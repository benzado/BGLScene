//
//  BGLPolygon.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/7/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import "BGLPolygon.h"
#import "BGLManifest.h"
#import "BGLProgram.h"


@implementation BGLPolygon


+ (BGLPolygon *)polygonWithRect:(CGRect)rect color:(BGLColor)color
{
    return [self polygonWithRect:rect topColor:color bottomColor:color];
}


+ (BGLPolygon *)polygonWithRect:(CGRect)rect topColor:(BGLColor)topColor bottomColor:(BGLColor)bottomColor
{
    BGLPolygon *polygon = [[BGLPolygon alloc] init];
    [polygon setColor:topColor];
    [polygon addVertexAtPosition:BGLVector2Make(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [polygon addVertexAtPosition:BGLVector2Make(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    [polygon setColor:bottomColor];
    [polygon addVertexAtPosition:BGLVector2Make(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    [polygon addVertexAtPosition:BGLVector2Make(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    return [polygon autorelease];
}


@synthesize mode;


- (id)init
{
    if ((self = [super init])) {
        self.program = [BGLProgram programNamed:@"Polygon"];
        mode = GL_TRIANGLE_STRIP;
        vertexData = [[NSMutableData alloc] init];
        nextVertex.color = BGLColorWhite;
    }
    return self;
}


- (void)dealloc
{
    [vertexData release];
    [super dealloc];
}


- (void)setColor:(BGLColor)color
{
    nextVertex.color = color;
}


- (void)addVertexAtPosition:(BGLVector2)position
{
    nextVertex.position = position;
    [vertexData appendBytes:(const void *)&nextVertex 
                     length:sizeof(BGLPolygonVertex)];
}


#pragma mark Renderable


- (void)render
{
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    
    const BGLPolygonVertex *data = [vertexData bytes];
    
    glVertexAttribPointer(sha_Polygon_vertexPosition, 2, GL_FLOAT, GL_FALSE, sizeof(BGLPolygonVertex), &data->position);
    glEnableVertexAttribArray(sha_Polygon_vertexPosition);
    glVertexAttribPointer(sha_Polygon_vertexColor, 3, GL_FLOAT, GL_FALSE, sizeof(BGLPolygonVertex), &data->color);
    glEnableVertexAttribArray(sha_Polygon_vertexColor);
    
    DAssert([self.program validate], @"Failed to validate program.");
    
    int count = [vertexData length] / sizeof(BGLPolygonVertex);
    
    glDrawArrays(mode, 0, count);
}


@end
