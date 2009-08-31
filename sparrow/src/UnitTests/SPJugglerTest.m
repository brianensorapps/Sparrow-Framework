//
//  SPJugglerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.08.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPTween.h"
#import "SPJuggler.h"

// -------------------------------------------------------------------------------------------------

@interface SPJugglerTest : SenTestCase 
{
    SPJuggler *mJuggler;
    SPQuad *mQuad;    
    BOOL mStartedReached;
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPJugglerTest

- (void)setUp
{
    mStartedReached = NO;
}

- (void)testModificationWhileInEvent
{    
    mJuggler = [[SPJuggler alloc] init];
    
    SPQuad *quad = [[SPQuad alloc] initWithWidth:100 height:100];    
    SPTween *tween = [SPTween tweenWithTarget:quad time:1.0f];
    [tween addEventListener:@selector(onTweenCompleted:) atObject:self 
                    forType:SP_EVENT_TYPE_TWEEN_COMPLETED];    
    [mJuggler addObject:tween];
    
    [mJuggler advanceTime:0.4]; // -> 0.4 (start)
    [mJuggler advanceTime:0.4]; // -> 0.8 (update)    
    
    STAssertNoThrow([mJuggler advanceTime:0.4], // -> 1.2 (complete)
                    @"juggler could not cope with modification in tween callback");
    
    [mJuggler advanceTime:0.4]; // 1.6 (start of new tween)
    STAssertTrue(mStartedReached, @"juggler ignored modification made in callback");    
}

- (void)onTweenCompleted:(SPEvent*)event
{
    SPTween *tween = [SPTween tweenWithTarget:mQuad time:1.0f];        
    [tween addEventListener:@selector(onTweenStarted:) atObject:self 
                    forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [mJuggler addObject:tween];
}

- (void)onTweenStarted:(SPEvent*)event
{
    mStartedReached = YES;
}

- (void)dealloc
{
    [mJuggler release];
    [mQuad release];
    [super dealloc];
}

@end