//
//  BGLUtilities.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat a;
} BGLColor;

static const BGLColor BGLColorWhite = { 1, 1, 1, 1 };
static const BGLColor BGLColorBlack = { 0, 0, 0, 1 };
static const BGLColor BGLColorGray = { 0.5f,0.5f,0.5f, 1.f };

static inline void BGLUniformColor(const GLint location, const BGLColor *color)
{
    glUniform4fv(location, 1, (const GLfloat *)color);
}

static inline BGLColor BGLColorMake4b(const GLubyte r, const GLubyte g, const GLubyte b, const GLubyte a)
{
    BGLColor color;
    color.r = r / 255.f;
    color.g = g / 255.f;
    color.b = b / 255.f;
    color.a = a / 255.f;
    return color;
}

static inline BGLColor BGLColorMake4f(const GLfloat r, const GLfloat g, const GLfloat b, const GLfloat a)
{
    BGLColor color;
    color.r = r;
    color.g = g;
    color.b = b;
    color.a = a;
    return color;
};

static inline BGLColor BGLColorAdd(const BGLColor a, const BGLColor b)
{
    return BGLColorMake4f(a.r+b.r, a.g+b.g, a.b+b.b, a.a+b.a);
}

static inline BGLColor BGLColorMultiply(const BGLColor a, const BGLColor b)
{
    return BGLColorMake4f(a.r*b.r, a.g*b.g, a.b*b.b, a.a*b.a);
}

static inline BOOL BGLColorEquals(const BGLColor a, const BGLColor b)
{
    return (a.r == b.r) && (a.g == b.g) && (a.b == b.b) && (a.a == b.a);
};

typedef void (*GLInfoFunc)(GLuint name, GLenum pname, GLint *params);
typedef void (*GLLogFunc)(GLuint name, GLsizei bufsize, GLsizei *length, GLchar *buf);

NSString *BGLStringForLogInfo(GLuint name, GLInfoFunc infoFunc, GLLogFunc logFunc);

typedef void (*GLGetItemFunc)(GLuint program, GLuint index, GLsizei bufsize, GLsizei *length, GLint *size, GLenum *type, GLchar *name);
typedef int (*GLItemLocationFunc)(GLuint program, const GLchar* name);

NSDictionary *BGLDictionaryFromProgram(GLuint name, GLenum maxLengthEnum, GLenum countEnum, GLGetItemFunc getItemFunc, GLItemLocationFunc itemLocationFunc);