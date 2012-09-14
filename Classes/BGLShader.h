//
//  BGLShader.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface BGLShader : NSObject {
    GLuint name;
}
@property (nonatomic,readonly) GLuint name;
+ (BGLShader *)loadVertexShaderNamed:(NSString *)rsrcName;
+ (BGLShader *)loadFragmentShaderNamed:(NSString *)rsrcName;
- (id)initWithType:(GLenum)shaderType source:(NSString *)source;
- (NSString *)infoLog;
@end
