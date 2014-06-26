//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

// Set Scroll Speed
static const CGFloat scrollSpeed = 200.f;

@implementation MainScene {
    CCSprite *_glider;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_ceiling1;
    CCNode *_ceiling2;
    NSArray *_grounds;
    NSArray *_ceilings;
    NSTimeInterval _sinceTouch;
}

-(void)didLoadFromCCB
{
    // Accept interaction from user
    self.userInteractionEnabled = YES;
    
    // Set Array of grounds
    _grounds = @[_ground1,_ground2];
    
    // Set Array of ceilings
    _ceilings = @[_ceiling1, _ceiling2];
}

-(void)update:(CCTime)delta
{
    // Move the glider and physics node
    _glider.position = ccp(_glider.position.x + delta * scrollSpeed, _glider.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed * delta), _physicsNode.position.y);
    
    // Clamp glider velocity
    float yVelocity = clampf(_glider.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _glider.physicsBody.velocity = ccp(0, yVelocity);
    
    /*** GLIDER ROTATION ***/
    // - Limit rotation of glider
    // - Start downward rotation after a while without touch
    _sinceTouch += delta;
    _glider.rotation = clampf(_glider.rotation, -5.f, 5.f);
    if (_glider.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_glider.physicsBody.angularVelocity, -1.f, 1.f);
        _glider.physicsBody.angularVelocity = angularVelocity;
    }
    if ((_sinceTouch > 0.05f)) {
        [_glider.physicsBody applyAngularImpulse:6050.f * delta];
    }
    
    /*** LOOPING ***/
    // Loop Ground
    for (CCNode *ground in _grounds) {
        
        // Get ground position in world
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        
        // Get ground position in screen
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        // If left corner is 1 width off the screen, move right
        if (groundScreenPosition.x <= (-1 * 592)) {
            ground.position = ccp(ground.position.x + 2 * 592, ground.position.y);
        }
    }
    
    // Loop Ceiling
    for (CCNode *ceiling in _ceilings) {
        
        // Get ceiling position in world
        CGPoint ceilingWorldPosition = [_physicsNode convertToWorldSpace:ceiling.position];
        
        // Get ceiling position in screen
        CGPoint ceilingScreenPosition = [self convertToNodeSpace:ceilingWorldPosition];
        
        // If left corner is 1 width off the screen, move right
        if (ceilingScreenPosition.x <= (-1 * 592)) {
            ceiling.position = ccp(ceiling.position.x + 2 * 592, ceiling.position.y);
        }
    }
}

#pragma mark - Touch Functions

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self schedule:@selector(applyForce) interval:0.10];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self unscheduleAllSelectors];
}

#pragma mark - Helper Functions

-(void)applyForce
{
    // Apply impulse on touch
    [_glider.physicsBody applyImpulse:ccp(0, 800.f)];
    
    // Apply angular impulse on touch
    [_glider.physicsBody applyAngularImpulse:-1050.f];
    _sinceTouch = 0.f;
}

@end
