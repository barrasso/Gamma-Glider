//
//  Obstacle.h
//  GammaGlider
//
//  Created by Mark on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Obstacle : CCNode

@property (nonatomic, assign) int obstacleHealth;

-(void)didLoadFromCCB;
-(void)setupRandomPosition;

@end
