//
//  TTActivity.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>
#import "TTTic.h"

@interface TTActivity : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) TTTic *tic;

+ (instancetype)activityWithType:(NSString *)type;
+ (instancetype)activityWithType:(NSString *)type tic:(TTTic *)tic;

@end
