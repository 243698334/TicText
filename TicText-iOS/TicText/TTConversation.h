//
//  TTConversation.h
//  TicText
//
//  Created by Kevin Yufei Chen on 3/18/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>

#import "TTUser.h"
#import "TTTic.h"

@interface TTConversation : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) TTUser *recipient;
@property (nonatomic, strong) TTTic *lastTic;

- (NSDate *)lastActivityTimestamp;

@end