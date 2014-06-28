//
//  Obstacle.m
//  GammaGlider
//
//  Created by Mark on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle

#define ARC4RANDOM_MAX      0x100000000
static const CGFloat maxYPosition = 500.f;
static const CGFloat minYPosition = 20.f;
static const CGFloat xPosition = 50.f;

-(void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"obstacle";
}

-(void)setupRandomPosition
{
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maxYPosition - minYPosition;
    
    self.position = ccp(self.position.x + (random * xPosition), self.position.y + (random * range));
}

@end
