//
//  BGLUtilities.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLUtilities.h"


// Thanks: http://iphonedevelopment.blogspot.com/2010/06/code-as-if.html

NSString *BGLStringForLogInfo(GLuint name, GLInfoFunc infoFunc, GLLogFunc logFunc)
{
    GLint logLength = 0, charsWritten = 0;
    infoFunc(name, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength < 1) return nil;
    
    GLchar *logBytes = malloc(logLength);
    logFunc(name, logLength, &charsWritten, logBytes);
    NSString *logString = [[NSString alloc] initWithBytes:logBytes
                                                   length:logLength
                                                 encoding:NSUTF8StringEncoding];
    free(logBytes);
    return [logString autorelease];
}


NSDictionary *BGLDictionaryFromProgram(GLuint name, GLenum maxLengthEnum, GLenum countEnum, GLGetItemFunc getItemFunc, GLItemLocationFunc itemLocationFunc)
{
    GLsizei bufsize;
    GLint count;
    
    glGetProgramiv(name, maxLengthEnum, &bufsize);
    glGetProgramiv(name, countEnum, &count);
    
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:count];
    
    GLchar *buffer = malloc(bufsize);
    
    for (GLuint i = 0; i < count; i++) {
        GLsizei length;
        GLint size;
        GLenum type;
        getItemFunc(name, i, bufsize, &length, &size, &type, buffer);
        GLint location = itemLocationFunc(name, buffer);
        NSString *key = [[NSString alloc] initWithBytes:buffer length:length encoding:NSUTF8StringEncoding];
        [map setObject:[NSNumber numberWithInt:location] forKey:key];
        [key release];
    }
    
    free(buffer);
    
    return map;
}
