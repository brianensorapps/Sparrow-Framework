//
//  SPQuadTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 23.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <math.h>

#import "SPMatrix.h"
#import "SPMacros.h"
#import "SPPoint.h"
#import "SPSprite.h"
#import "SPQuad.h"

// -------------------------------------------------------------------------------------------------

@interface SPQuadTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPQuadTest

- (void)testProperties
{
    float width = 30.0f;
    float height = 20.0f;
    float x = 3;
    float y = 2;
    
    SPQuad *quad = [[SPQuad alloc] initWithWidth:width height:height];
    quad.x = x; 
    quad.y = y;
    
    STAssertTrue(SP_IS_FLOAT_EQUAL(x, quad.x), @"wrong x");
    STAssertTrue(SP_IS_FLOAT_EQUAL(y, quad.y), @"wrong y");
    STAssertTrue(SP_IS_FLOAT_EQUAL(width, quad.width), @"wrong width");
    STAssertTrue(SP_IS_FLOAT_EQUAL(height, quad.height), @"wrong height");
}

- (void)testWidthAfterRotation
{
    float width = 30;
    float height = 40;
    float angle = SP_D2R(45.0f);
    SPQuad *quad = [[SPQuad alloc] initWithWidth:width height:height];
    quad.rotation = angle;

    float expectedWidth = cosf(angle) * (width + height);
    STAssertTrue(SP_IS_FLOAT_EQUAL(expectedWidth, quad.width), @"wrong width: %f", quad.width);
}

- (void)testVertexColorAndAlpha
{
    SPQuad *quad = [SPQuad quadWithWidth:20 height:20];
    
    [quad setColor:0xff0000 ofVertex:0];
    [quad setColor:0x00ff00 ofVertex:1];
    [quad setColor:0x0000ff ofVertex:2];
    [quad setColor:0xff00ff ofVertex:3];
    
    STAssertEquals((uint)0xff0000, [quad colorOfVertex:0], @"wrong vertex color");
    STAssertEquals((uint)0x00ff00, [quad colorOfVertex:1], @"wrong vertex color");
    STAssertEquals((uint)0x0000ff, [quad colorOfVertex:2], @"wrong vertex color");
    STAssertEquals((uint)0xff00ff, [quad colorOfVertex:3], @"wrong vertex color");
    
    STAssertEquals(1.0f, [quad alphaOfVertex:0], @"wrong vertex alpha");
    STAssertEquals(1.0f, [quad alphaOfVertex:1], @"wrong vertex alpha");
    STAssertEquals(1.0f, [quad alphaOfVertex:2], @"wrong vertex alpha");
    STAssertEquals(1.0f, [quad alphaOfVertex:3], @"wrong vertex alpha");
    
    [quad setAlpha:0.2 ofVertex:0];
    [quad setAlpha:0.4 ofVertex:1];
    [quad setAlpha:0.6 ofVertex:2];
    [quad setAlpha:0.8 ofVertex:3];
    
    STAssertEquals((uint)0xff0000, [quad colorOfVertex:0], @"wrong vertex color");
    STAssertEquals((uint)0x00ff00, [quad colorOfVertex:1], @"wrong vertex color");
    STAssertEquals((uint)0x0000ff, [quad colorOfVertex:2], @"wrong vertex color");
    STAssertEquals((uint)0xff00ff, [quad colorOfVertex:3], @"wrong vertex color");
    
    STAssertEquals(0.2f, [quad alphaOfVertex:0], @"wrong vertex alpha");
    STAssertEquals(0.4f, [quad alphaOfVertex:1], @"wrong vertex alpha");
    STAssertEquals(0.6f, [quad alphaOfVertex:2], @"wrong vertex alpha");
    STAssertEquals(0.8f, [quad alphaOfVertex:3], @"wrong vertex alpha");
}

@end

#endif