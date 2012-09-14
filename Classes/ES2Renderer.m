//
//  ES2Renderer.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "ES2Renderer.h"
#import "BGLNode.h"
#import "BGLRenderState.h"


@implementation ES2Renderer

// Create an OpenGL ES 2.0 context
- (id)init
{
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }
        
        [self genBuffers];
    }

    return self;
}


- (void)genBuffers
{
    GLuint fbs[2];
    GLuint rbs[3];
    
    glGenFramebuffers(2, fbs);
    glGenRenderbuffers(3, rbs);
    
    displayFramebuffer = fbs[0];
    defaultFramebuffer = fbs[1];
    displayRenderbuffer = rbs[0];
    colorRenderbuffer = rbs[1];
    depthRenderbuffer = rbs[2];
    
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
}


- (BOOL)allocateBufferStorageForLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete display framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

#if TARGET_IPHONE_SIMULATOR
    static const GLint samples = 1;
#else
    static const GLint samples = 4;
#endif
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samples, GL_RGB5_A1, backingWidth, backingHeight);
    
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samples, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete default framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    return YES;
}


- (void)deleteBuffers
{
    const GLuint fbs[] = { defaultFramebuffer, displayFramebuffer };
    const GLuint rbs[] = { colorRenderbuffer, depthRenderbuffer, displayRenderbuffer };
    glDeleteFramebuffers(2, fbs);
    glDeleteRenderbuffers(3, rbs);
    defaultFramebuffer = 0;
    displayFramebuffer = 0;
    colorRenderbuffer = 0;
    depthRenderbuffer = 0;
    displayRenderbuffer = 0;
}


- (void)renderRootNode:(BGLNode *)rootNode
{
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    // [EAGLContext setCurrentContext:context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glViewport(0, 0, backingWidth, backingHeight);
    
    // Clear background
    glClearColor(0, 0, 0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    BGLRenderState *state = [[BGLRenderState alloc] init];
    [rootNode renderSelfAndSubnodesWithState:state];
    [state release];
    
    glDisable(GL_SCISSOR_TEST);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, defaultFramebuffer);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, displayFramebuffer);
    glResolveMultisampleFramebufferAPPLE();
    
    // Hint to hardware that we're not going to look at these buffers again,
    // so feel free to trash them for performance's sake.
    GLenum attachments[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT };
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
    
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)dealloc
{
    [self deleteBuffers];

    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }

    [context release];
    context = nil;

    [super dealloc];
}

@end
