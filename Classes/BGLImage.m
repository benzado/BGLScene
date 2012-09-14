//
//  BGLImage.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/6/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import "BGLImage.h"
#import "BGLProgram.h"
#import "BGLTexture.h"
#import "BGLManifest.h"


@implementation BGLImage


- (id)initWithTexture:(GLuint)tx frame:(CGRect)aFrame size:(CGSize)aSize
{
    if ((self = [super init])) {
        self.program = [BGLProgram programNamed:@"Text"];
        texture = tx;
        
        CGFloat x0 = 0;
        CGFloat y0 = 0;
        CGFloat x1 = CGRectGetWidth(aFrame);
        CGFloat y1 = -CGRectGetHeight(aFrame);
        
        CGFloat tx0 = CGRectGetMinX(aFrame) / aSize.width;
        CGFloat ty0 = CGRectGetMinY(aFrame) / aSize.height;
        CGFloat tx1 = CGRectGetMaxX(aFrame) / aSize.width;
        CGFloat ty1 = CGRectGetMaxY(aFrame) / aSize.height;
        
        BGLImageVertex *v;
        
        v = &vertexes[0]; v->x=x0; v->y=y0; v->tx=tx0; v->ty=ty0;
        v = &vertexes[1]; v->x=x1; v->y=y0; v->tx=tx1; v->ty=ty0;
        v = &vertexes[2]; v->x=x0; v->y=y1; v->tx=tx0; v->ty=ty1;
        v = &vertexes[3]; v->x=x1; v->y=y1; v->tx=tx1; v->ty=ty1;
    }
    return self;
}


#pragma mark Renderable


- (void)render
{
    glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    
    BGLUniformColor(SHU[shu_Text_color], &BGLColorBlack);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(SHU[shu_Text_sampler], 0);

    glVertexAttribPointer(sha_Text_vertexPosition, 2, GL_FLOAT, GL_FALSE, 
                          sizeof(BGLImageVertex), &vertexes[0].x);
    glEnableVertexAttribArray(sha_Text_vertexPosition);

    glVertexAttribPointer(sha_Text_vertexTexCoord, 2, GL_FLOAT, GL_FALSE,
                          sizeof(BGLImageVertex), &vertexes[0].tx);
    glEnableVertexAttribArray(sha_Text_vertexTexCoord);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


@end
