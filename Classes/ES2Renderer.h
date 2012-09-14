//
//  ES2Renderer.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer, depthRenderbuffer;
    GLuint displayFramebuffer, displayRenderbuffer;
}

@end

