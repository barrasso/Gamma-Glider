//
//  Player.m
//  GammaGlider
//
//  Created by Mark on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player

-(void)didLoadFromCCB
{
   self.physicsBody.collisionType = @"player";
}

@end
