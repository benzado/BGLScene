//
//  BGLProgram.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "BGLMatrix.h"

extern GLint *SHU;


@class BGLShader;
@class BGLRenderState;


@interface BGLProgram : NSObject {
    GLuint name;
    NSMutableArray *shadersArray;
    BGLMatrix projectionMatrix;
    GLint projectionMatrixUniformLocation;
    GLint modelViewMatrixUniformLocation;
    GLint modelViewProjectionMatrixUniformLocation;
}
+ (BOOL)loadManifestNamed:(NSString *)manifestName;
+ (GLuint)textureNamed:(NSString *)textureName;
+ (BGLProgram *)programNamed:(NSString *)programName;
- (void)attachShader:(BGLShader *)shader;
- (void)bindAttributeLocation:(GLuint)location toName:(const GLchar *)str;
- (BOOL)link;
- (BOOL)validate;
- (void)use;
- (NSDictionary *)activeAttributeLocations;
- (NSDictionary *)activeUniformLocations;
- (GLint)attributeLocationNamed:(const GLchar *)str;
- (GLint)uniformLocationNamed:(const GLchar *)str;
- (NSString *)infoLog;
- (void)setProjectionMatrix:(BGLMatrix)matrix;
- (void)applyUniformsFromState:(BGLRenderState *)state;
@end
