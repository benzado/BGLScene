//
//  BGLProgram.m
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/3/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import "BGLProgram.h"
#import "BGLShader.h"
#import "BGLUtilities.h"
#import "BGLRenderState.h"
#import "BGLTexture.h"


static NSDictionary *loadedPrograms = nil;
static NSMutableDictionary *loadedVertexShaders = nil;
static NSMutableDictionary *loadedFragmentShaders = nil;
static NSMutableDictionary *loadedTextures = nil;


GLint *SHU = nil;


@implementation BGLProgram


+ (BGLShader *)vertexShaderNamed:(NSString *)name
{
    BGLShader *shader = [loadedVertexShaders objectForKey:name];
    if (shader == nil) {
        if (loadedVertexShaders == nil) {
            loadedVertexShaders = [[NSMutableDictionary alloc] init];
        }
        shader = [BGLShader loadVertexShaderNamed:name];
        [loadedVertexShaders setObject:shader forKey:name];
     }
    return shader;
}


+ (BGLShader *)fragmentShaderNamed:(NSString *)name
{
    BGLShader *shader = [loadedFragmentShaders objectForKey:name];
    if (shader == nil) {
        if (loadedFragmentShaders == nil) {
            loadedFragmentShaders = [[NSMutableDictionary alloc] init];
        }
        shader = [BGLShader loadFragmentShaderNamed:name];
        [loadedFragmentShaders setObject:shader forKey:name];
    }
    return shader;
}


+ (BOOL)loadManifestNamed:(NSString *)manifestName
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:manifestName ofType:@"plist"];
    ZAssert(path, @"Resource %@ not found!", path);

    // This should only be called once.
    
    if (SHU != NULL) {
        [NSException raise:@"BGLProgramException"
                    format:@"Multiple attempts to load a manifest detected."];
    }
    
    NSDictionary *manifest = [NSDictionary dictionaryWithContentsOfFile:path];
    ZAssert(manifest, @"Could not parse manifest at path '%@'", path);
    
    // Load Textures

    NSMutableDictionary *loaded = [NSMutableDictionary dictionary];
    
    for (NSDictionary *txInfo in [manifest objectForKey:@"Textures"]) {
        NSString *name = [txInfo objectForKey:@"Name"];
        GLenum format = [[txInfo objectForKey:@"Format"] unsignedIntValue];
        GLuint t = BGLTextureLoadByName((CFStringRef)name, format);
        if (t) {
            [loaded setObject:[NSNumber numberWithUnsignedInt:t] forKey:name];
        } else {
            [NSException raise:@"BGLProgramException"
                        format:@"Couldn't load texture %@", name];
        }
    }
    
    loadedTextures = [loaded copy];
    
    // Load Programs

    [loaded removeAllObjects]; // reuse temporary storage
    
    int unifCount = 0;
    for (NSDictionary *info in [manifest objectForKey:@"Programs"]) {
        unifCount += [[info objectForKey:@"Uniforms"] count];
    }
    SHU = calloc(unifCount, sizeof(GLint));
        
    GLint unifLoc = 0;
    
    for (NSDictionary *info in [manifest objectForKey:@"Programs"]) {
        NSString *programName = [info objectForKey:@"Name"];
        NSString *vshName = [info objectForKey:@"VertexShaderName"];
        NSString *fshName = [info objectForKey:@"FragmentShaderName"];
        
        BGLProgram *program;

        NSString *programClassName = [info objectForKey:@"Class"];
        if (programClassName) {
            Class c = NSClassFromString(programClassName);
            program = [[c alloc] init];
        } else {
            program = [[BGLProgram alloc] init];
        }
        [program attachShader:[self vertexShaderNamed:vshName]];
        [program attachShader:[self fragmentShaderNamed:fshName]];
        // Bind Attribute Locations
        GLint attrLoc = 0;
        for (NSString *attrName in [info objectForKey:@"Attributes"]) {
            [program bindAttributeLocation:attrLoc++ toName:[attrName UTF8String]];
        }
        // Link
        if ([program link]) {
            // Get Uniform Locations
            NSArray *uniformNames = [info objectForKey:@"Uniforms"];
            for (NSString *unifName in uniformNames) {
                SHU[unifLoc++] = [program uniformLocationNamed:[unifName UTF8String]];
            }
            [loaded setObject:program forKey:programName];
        } else {
            DLog(@"Failed to load program %@", programName);
            [program release];
            return NO;
        }
        [program release];
    }
    
    loadedPrograms = [loaded copy];
    
    return YES;
}


+ (GLuint)textureNamed:(NSString *)textureName
{
    NSNumber *n = [loadedTextures objectForKey:textureName];
    ZAssert(n, @"No such texture named '%@'", textureName);
    return [n unsignedIntValue];
}


+ (BGLProgram *)programNamed:(NSString *)programName
{
    BGLProgram *program = [loadedPrograms objectForKey:programName];
    ZAssert(program, @"No program %@ found!", programName);
    return program;
}


- (id)init
{
    if ((self = [super init])) {
        name = glCreateProgram();
        if (name == 0) {
            [self release];
            return nil;
        }
        BGLMatrixLoadIdentity(projectionMatrix);
        shadersArray = [[NSMutableArray alloc] init];
        projectionMatrixUniformLocation = -1;
        modelViewMatrixUniformLocation = -1;
        modelViewProjectionMatrixUniformLocation = -1;
    }
    return self;
}


- (void)dealloc
{
    [shadersArray release];
    glDeleteProgram(name);
    [super dealloc];
}


- (void)attachShader:(BGLShader *)shader
{
    [shadersArray addObject:shader];
    glAttachShader(name, shader.name);
    DLog(@"Shader %d attached to Program %d", shader.name, name);
}


- (void)bindAttributeLocation:(GLuint)location toName:(const GLchar *)str
{
    // The attribute name does not have to actually be in the linked program; this allows you to set up a global mapping of names to indices and simply always use them for every program you create.
    glBindAttribLocation(name, location, str);
}


- (BOOL)link
{
    glLinkProgram(name);
    NSString *log = [self infoLog];
    if (log) {
        DLog(@"Program %d link log:\n%@", name, log);
    }
    GLint status;
    glGetProgramiv(name, GL_LINK_STATUS, &status);
    if (status != 0) {
        DLog(@"Program %d uniforms:\n%@", name, [self activeUniformLocations]);
        DLog(@"Program %d attributes:\n%@", name, [self activeAttributeLocations]);
        projectionMatrixUniformLocation = [self uniformLocationNamed:"projectionMatrix"];
        modelViewMatrixUniformLocation = [self uniformLocationNamed:"modelViewMatrix"];
        modelViewProjectionMatrixUniformLocation = [self uniformLocationNamed:"modelViewProjectionMatrix"];
    }
    return (status != 0);
}


- (BOOL)validate
{
    glValidateProgram(name);
    NSString *log = [self infoLog];
    if (log) {
        NSLog(@"Program %d validate log:\n%@", name, log);
    }
    GLint status;
    glGetProgramiv(name, GL_VALIDATE_STATUS, &status);
    return (status != 0);
}


- (void)use
{
    glUseProgram(name);
}


- (NSDictionary *)activeAttributeLocations
{
    return BGLDictionaryFromProgram(name,
                                    GL_ACTIVE_ATTRIBUTE_MAX_LENGTH,
                                    GL_ACTIVE_ATTRIBUTES, 
                                    glGetActiveAttrib,
                                    glGetAttribLocation);
}


- (NSDictionary *)activeUniformLocations
{
    return BGLDictionaryFromProgram(name,
                                    GL_ACTIVE_UNIFORM_MAX_LENGTH,
                                    GL_ACTIVE_UNIFORMS,
                                    glGetActiveUniform,
                                    glGetUniformLocation);
}


- (GLint)attributeLocationNamed:(const GLchar *)str
{
    return glGetAttribLocation(name, str);
}


- (GLint)uniformLocationNamed:(const GLchar *)str
{
    return glGetUniformLocation(name, str);
}


- (NSString *)infoLog
{
    return BGLStringForLogInfo(name, glGetProgramiv, glGetProgramInfoLog);
}


- (void)setProjectionMatrix:(BGLMatrix)matrix
{
    BGLMatrixCopy(projectionMatrix, matrix);
}


- (void)applyUniformsFromState:(BGLRenderState *)state
{
    if (projectionMatrixUniformLocation > -1) {
        glUniformMatrix4fv(projectionMatrixUniformLocation, 1, GL_FALSE, projectionMatrix);
    }
    if (modelViewMatrixUniformLocation > -1 || modelViewProjectionMatrixUniformLocation > -1) {
        BGLMatrix matrix;
        [state getModelViewMatrix:matrix];
        if (modelViewMatrixUniformLocation > -1) {
            glUniformMatrix4fv(modelViewMatrixUniformLocation, 1, GL_FALSE, matrix);
        }
        if (modelViewProjectionMatrixUniformLocation > -1) {
            BGLMatrixMultiply(matrix, projectionMatrix, matrix);
            glUniformMatrix4fv(modelViewProjectionMatrixUniformLocation, 1, GL_FALSE, matrix);
        }
    }
}


@end
