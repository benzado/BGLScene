//
//  BGLTextNode.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/22/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>

#import "BGLBasicAnimation.h"
#import "BGLTextNode.h"
#import "BGLProgram.h"
#import "BGLShader.h"
#import "BGLUtilities.h"
#import "BGLTexture.h"
#import "BGLScene.h"

#import "BGLManifest.h"


static NSMutableDictionary *loadedFonts = nil;


@implementation BGLTextNode


+ (BGLFontRef)fontNamed:(NSString *)fontName
{
    if (loadedFonts == nil) {
        loadedFonts = [[NSMutableDictionary alloc] initWithCapacity:8];
    }
    NSValue *value = [loadedFonts objectForKey:fontName];
    if (value == nil) {
        NSURL *fontURL = [[NSBundle mainBundle] URLForResource:fontName withExtension:@"bglfont"];
        BGLFontRef font = BGLFontCreateWithURL((CFURLRef)fontURL);
        DAssert(font != NULL, @"No font named '%@'", fontName);
        value = [NSValue valueWithPointer:font];
        [loadedFonts setObject:value forKey:fontName];
    }
    return (BGLFontRef)[value pointerValue];
}


@synthesize color;


- (id)initWithFontName:(NSString *)fontName
{
    if ((self = [super init])) {
        self.program = [BGLProgram programNamed:@"Text"];
        font = BGLFontRetain([BGLTextNode fontNamed:fontName]);
    }
    return self;
}


- (void)dealloc
{
    BGLFontRelease(font);
    BGLTextRelease(text);
    [super dealloc];
}


- (float)width
{
    return BGLTextGetWidth(text);
}


- (float)height
{
    return BGLTextGetHeight(text);
}


- (void)setString:(NSString *)string
{
    if (text) BGLTextRelease(text);
    unichar *buffer = malloc([string length] * sizeof(unichar));
    [string getCharacters:buffer range:NSMakeRange(0, [string length])];
    text = BGLTextCreate(font, buffer, [string length]);
    free(buffer);
}


- (void)setAlpha:(float)f
{
    color.a = f;
}


- (BGLAnimation *)pulseAnimation
{
    BGLBasicAnimation *pulse = [BGLBasicAnimation animationWithTarget:self selector:@selector(setAlpha:)];
    pulse.initialScalar = 0.6f;
    pulse.finalScalar = 0.3f;
    pulse.duration = 4;
    pulse.curveFunc = &BGLScalarCurvePulse;
    pulse.repeatCount = kBGLScalarRepeatForever;
    return pulse;
}


- (void)centerAt:(BGLVector3)position
{
    [self resetModelViewMatrix];
    [self translateBy:BGLVector3Make(position.x - 0.5f * BGLTextGetWidth(text),
                                     position.y - 0.5f * BGLTextGetHeight(text),
                                     position.z)];
}


- (void)leftAlignAt:(BGLVector3)position
{
    [self resetModelViewMatrix];
    [self translateBy:BGLVector3Make(position.x,
                                     position.y - 0.5f * BGLTextGetHeight(text),
                                     position.z)];
}


- (void)rightAlignAt:(BGLVector3)position
{
    [self resetModelViewMatrix];
    [self translateBy:BGLVector3Make(position.x - BGLTextGetWidth(text),
                                     position.y - 0.5f * BGLTextGetHeight(text),
                                     position.z)];
}


#pragma mark BGLNode


- (void)render
{
    glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    BGLUniformColor(SHU[shu_Text_color], &color);
    BGLTextDraw(text, sha_Text_vertexPosition, sha_Text_vertexTexCoord, 
                SHU[shu_Text_sampler]);
}


@end
