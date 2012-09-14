//
//  ESRenderer.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@class BGLNode;

@protocol ESRenderer <NSObject>
- (void)genBuffers;
- (BOOL)allocateBufferStorageForLayer:(CAEAGLLayer *)layer;
- (void)renderRootNode:(BGLNode *)rootNode;
- (void)deleteBuffers;
@end
