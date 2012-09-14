//
//  BGLShader.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLShader.h"
#import "BGLUtilities.h"


@implementation BGLShader


@synthesize name;


+ (BGLShader *)loadShaderNamed:(NSString *)rsrcName ofType:(GLenum)type
{
    NSString *t;
    if (type == GL_VERTEX_SHADER) {
        t = @"vsh";
    } else if (type == GL_FRAGMENT_SHADER) {
        t = @"fsh";
    } else {
        ALog(@"Unknown Shader Type: %d", type);
        t = nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:rsrcName ofType:t];
    ZAssert(path != nil, @"Shader resource %@.%@ not found.", rsrcName, t);
    NSString *text = [NSString stringWithContentsOfFile:path 
                                               encoding:NSUTF8StringEncoding
                                                  error:NULL];
    ZAssert(text != nil, @"Shader resource at %@ empty.", path);
    return [[[BGLShader alloc] initWithType:type source:text] autorelease];
}


+ (BGLShader *)loadVertexShaderNamed:(NSString *)rsrcName
{
    return [self loadShaderNamed:rsrcName ofType:GL_VERTEX_SHADER];
}


+ (BGLShader *)loadFragmentShaderNamed:(NSString *)rsrcName
{
    return [self loadShaderNamed:rsrcName ofType:GL_FRAGMENT_SHADER];
}


- (id)initWithType:(GLenum)shaderType source:(NSString *)source
{
    if ((self = [super init])) {
        name = glCreateShader(shaderType);
        if (name == 0) {
            ALog(@"glCreateShader failed.");
            [self release];
            return nil;
        }
        const GLchar *sourceBytes = [source UTF8String];
        glShaderSource(name, 1, &sourceBytes, NULL);
        glCompileShader(name);
        NSString *log = [self infoLog];
        if (log) {
            DLog(@"Shader %d compile log:\n%@", name, log);
        }
        GLint status;
        glGetShaderiv(name, GL_COMPILE_STATUS, &status);
        if (status == GL_FALSE) {
            ALog(@"Failed to compile shader.");
            [self release];
            return nil;
        }
    }
    return self;
}


- (NSString *)infoLog
{
    return BGLStringForLogInfo(name, glGetShaderiv, glGetShaderInfoLog);
}


- (void)dealloc
{
    if (name) glDeleteShader(name);
    [super dealloc];
}


@end
