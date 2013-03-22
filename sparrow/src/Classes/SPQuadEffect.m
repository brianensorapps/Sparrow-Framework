//
//  SPBaseEffect.m
//  Sparrow
//
//  Created by Daniel Sperl on 12.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPQuadEffect.h"
#import "SPMatrix.h"
#import "SPTexture.h"
#import "SPProgram.h"
#import "SparrowClass.h"

NSString *getProgramName(BOOL hasTexture, BOOL useTinting)
{
    if (hasTexture)
    {
        if (useTinting) return @"SPQuad#11";
        else            return @"SPQuad#10";
    }
    else
    {
        if (useTinting) return @"SPQuad#01";
        else            return @"SPQuad#00";
    }
}

@implementation SPQuadEffect
{
    SPMatrix  *_mvpMatrix;
    SPTexture *_texture;
    float _alpha;
    BOOL _useTinting;
    BOOL _premultipliedAlpha;
    
    SPProgram *_program;
    int _aPosition;
    int _aColor;
    int _aTexCoords;
    int _uMvpMatrix;
    int _uAlpha;
}

@synthesize texture = _texture;
@synthesize alpha = _alpha;
@synthesize useTinting = _useTinting;

@synthesize attribPosition = _aPosition;
@synthesize attribColor = _aColor;
@synthesize attribTexCoords = _aTexCoords;

- (id)init
{
    if ((self = [super init]))
    {
        _mvpMatrix = [[SPMatrix alloc] init];
        _alpha = 1.0f;
    }
    return self;
}

- (void)prepareToDraw
{
    BOOL hasTexture = _texture != nil;
    BOOL useTinting = _useTinting || !_texture || _alpha != 1.0f;

    if (!_program)
    {
        NSString *programName = getProgramName(hasTexture, useTinting);
        _program = [Sparrow.currentController programByName:programName];
        
        if (!_program)
        {
            NSString *vertexShader   = [self vertexShaderForTexture:_texture   useTinting:useTinting];
            NSString *fragmentShader = [self fragmentShaderForTexture:_texture useTinting:useTinting];
            _program = [[SPProgram alloc] initWithVertexShader:vertexShader fragmentShader:fragmentShader];
            [Sparrow.currentController registerProgram:_program name:programName];
        }
        
        _aPosition  = [_program attributeByName:@"aPosition"];
        _aColor     = [_program attributeByName:@"aColor"];
        _aTexCoords = [_program attributeByName:@"aTexCoords"];
        _uMvpMatrix = [_program uniformByName:@"uMvpMatrix"];
        _uAlpha     = [_program uniformByName:@"uAlpha"];
    }
    
    GLKMatrix4 glkMvpMatrix = [_mvpMatrix convertToGLKMatrix4];
    
    glUseProgram(_program.name);
    glUniformMatrix4fv(_uMvpMatrix, 1, 0, glkMvpMatrix.m);
    
    if (useTinting)
    {
        if (_premultipliedAlpha) glUniform4f(_uAlpha, _alpha, _alpha, _alpha, _alpha);
        else                     glUniform4f(_uAlpha, 1.0f, 1.0f, 1.0f, _alpha);
    }
    
    if (hasTexture)
    {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture.name);
    }
}

- (NSString *)vertexShaderForTexture:(SPTexture *)texture useTinting:(BOOL)useTinting
{
    BOOL hasTexture = texture != nil;
    NSMutableString *source = [NSMutableString string];
    
    // variables
    
    [source appendString:@"attribute vec4 aPosition;"];
    if (useTinting) [source appendString:@"attribute vec4 aColor;"];
    if (hasTexture) [source appendString:@"attribute vec2 aTexCoords;"];

    [source appendString:@"uniform mat4 uMvpMatrix;"];
    if (useTinting) [source appendString:@"uniform vec4 uAlpha;"];
    
    if (useTinting) [source appendString:@"varying lowp vec4 vColor;"];
    if (hasTexture) [source appendString:@"varying lowp vec2 vTexCoords;"];
    
    // main
    
    [source appendString:@"void main()\n{"];
    
    [source appendString:@"  gl_Position = uMvpMatrix * aPosition;"];
    if (useTinting) [source appendString:@"  vColor = aColor * uAlpha;"];
    if (hasTexture) [source appendString:@"  vTexCoords  = aTexCoords;"];
    
    [source appendString:@"}"];
    
    return source;
}

- (NSString *)fragmentShaderForTexture:(SPTexture *)texture useTinting:(BOOL)useTinting
{
    BOOL hasTexture = texture != nil;
    NSMutableString *source = [NSMutableString string];
    
    // variables
    
    if (useTinting)
        [source appendString:@"varying lowp vec4 vColor;"];
    
    if (hasTexture)
    {
        [source appendString:@"varying lowp vec2 vTexCoords;"];
        [source appendString:@"uniform sampler2D uTexture;"];
    }
    
    // main
    
    [source appendString:@"void main()\n{"];
    
    if (hasTexture)
    {
        if (useTinting)
            [source appendString:@"gl_FragColor = texture2D(uTexture, vTexCoords) * vColor;"];
        else
            [source appendString:@"gl_FragColor = texture2D(uTexture, vTexCoords);"];
    }
    else
        [source appendString:@"gl_FragColor = vColor;"];
    
    [source appendString:@"}"];
    
    return source;
}

- (void)setMvpMatrix:(SPMatrix *)value
{
    [_mvpMatrix copyFromMatrix:value];
}

- (void)setAlpha:(float)value
{
    if ((value >= 1.0f && _alpha < 1.0f) || (value < 1.0f && _alpha >= 1.0f))
        _program = nil;
    
    _alpha = value;
}

- (void)setUseTinting:(BOOL)value
{
    if (value != _useTinting)
    {
        _useTinting = value;
        _program = nil;
    }
}

- (void)setTexture:(SPTexture *)value
{
    if ((_texture && !value) || (!_texture && value))
        _program = nil;
    
    _texture = value;
}

@end