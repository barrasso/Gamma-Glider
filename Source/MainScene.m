//
//  MainScene.m
//  Gamma Glider
//
//  Created by Mark on 06/26/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"
#import "Player.h"

// Set Scroll Speed
static const CGFloat scrollSpeed = 200.f;

// Set Obstacle Variables
static const CGFloat firstObstaclePosition = 650.f;
static const CGFloat distanceBetweenObstacles = 250.f;

@implementation MainScene {
    float distanceTravelled;
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_distanceLabel;
    CCSprite *_glider;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_ceiling1;
    CCNode *_ceiling2;
    Player *_player;
    NSArray *_grounds;
    NSArray *_ceilings;
    NSMutableArray *_obstacles;
    NSTimeInterval _sinceTouch;
}

-(void)didLoadFromCCB
{
    //debug physics
   // _physicsNode.debugDraw = YES;
    
    // Accept interaction from user
    self.userInteractionEnabled = YES;
    
    // Set Collision Delegate
    _physicsNode.collisionDelegate = self;
    
    // Set Collision Types
    self.physicsBody.collisionType = @"obstacle";
    self.physicsBody.collisionType = @"player";
    
    // Set Array of grounds
    _grounds = @[_ground1,_ground2];
    
    // Set Array of ceilings
    _ceilings = @[_ceiling1, _ceiling2];
    
    // Spawn New Obstacles
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
}

#pragma mark - Update (CCTIME)delta

-(void)update:(CCTime)delta
{
    // Update score label with the distance travelled
    distanceTravelled = distanceTravelled + 0.5;
    _distanceLabel.string = [NSString stringWithFormat:@"%.01f m",distanceTravelled];
    
    // Move the player and physics node
    _glider.position = ccp(_glider.position.x + delta * scrollSpeed, _glider.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed * delta), _physicsNode.position.y);
    
    // Clamp player velocity
    float yVelocity = clampf(_glider.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _glider.physicsBody.velocity = ccp(0, yVelocity);
    
    /*** GlIDER ROTATION ***/
    // - Limit rotation of player
    // - Start downward rotation after a while without touch
    _sinceTouch += delta;
    _glider.rotation = clampf(_glider.rotation, -3.f, 5.f);
    if (_glider.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_glider.physicsBody.angularVelocity, -1.f, 1.f);
        _glider.physicsBody.angularVelocity = angularVelocity;
    }
    if ((_sinceTouch > 0.8f)) {
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
        if (groundScreenPosition.x <= (-1 * 570)) {
            ground.position = ccp(ground.position.x + 2 * 570, ground.position.y);
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
    
    /*** OBSTACLES ***/
    // Spawn more obstacles when off screen
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
}

#pragma mark - Touch Functions

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // While user is touching the screen, applyForce to the player
    [self schedule:@selector(applyForce) interval:0.10];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // End applied force to player when not touching screen
    [self unscheduleAllSelectors];
}

#pragma  mark - Collision Functions

// Collisions between obstacle and player
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair obstacle:(CCNode *)nodeA player:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    // Get glider's current position
    CGPoint currentPosition = ccp(_glider.position.x, _glider.position.y);
    
    if (energy > 1.0f) {
        // If there is enough energy on impact
        // Make the obstacle explode
        [self obstacleExplode:nodeA];
        // Make the glider maintain his position
        _glider.position = currentPosition;

    }
}

#pragma mark - Player Functions

-(void)applyForce
{
    // Apply impulse on touch
    [_glider.physicsBody applyImpulse:ccp(0, 800.f)];
    
    // Apply angular impulse on touch
    [_glider.physicsBody applyAngularImpulse:-1050.f];
    _sinceTouch = 0.f;
}

#pragma mark - Obstacle Functions

-(void)spawnNewObstacle
{
    // Base new obstacle position on the previous obstacle's position
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if (!previousObstacle) {
        // This is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    // Load random Obstacle
    int asteroidNumber = arc4random() % 4;
    NSString *obstacleNumber = [NSString stringWithFormat:@"Obstacle%i", asteroidNumber];
    Obstacle *obstacle = (Obstacle*)[CCBReader load:obstacleNumber];
    
    //Set distance between Obstacles
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    
    // Setup obstacle's random position
    [obstacle setupRandomPosition];
    // Applied force to obstacle
    [obstacle.physicsBody applyForce:ccp(-10000.f, 0.f)];
    // Add to physics node and obstacle array
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

-(void)obstacleExplode:(CCNode *)obstacle
{
    // Load the Particle effect
    CCParticleSystem *explode = (CCParticleSystem *)[CCBReader load:@"ObstacleExplosion"];
    
    // Clean up particle effect
    explode.autoRemoveOnFinish = YES;
    
    // Place particle effect on obstacle's position
    explode.position = obstacle.position;
    
    // Add particle effect to same node as obstacle
    [obstacle.parent addChild:explode];
    
    // Remove obstacle
    [obstacle removeFromParent];
}

@end
