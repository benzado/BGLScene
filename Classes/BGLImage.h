//
//  BGLImage.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 11/6/10.
//  Copyright 2010 Heroic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLNode.h"
#import "BGLMatrix.h"
#import "BGLUtilities.h"


typedef struct _BGLImageVertex {
    GLfloat x;
    GLfloat y;
    GLfloat tx;
    GLfloat ty;
} BGLImageVertex;


@interface BGLImage : BGLNode {
    GLint texture;
    BGLImageVertex vertexes[4];
}
- (id)initWithTexture:(GLuint)tx frame:(CGRect)aFrame size:(CGSize)aSize;
@end
