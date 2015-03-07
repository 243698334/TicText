//
//  TTTic.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>
#import "TTUser.h"

@interface TTTic : PFObject<PFSubclassing>

@property (nonatomic) NSTimeInterval timeLimit;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSData *content;
@property (nonatomic, strong) NSDate *sendTimestamp;
@property (nonatomic, strong) NSDate *receiveTimestamp;
@property (nonatomic, strong) TTUser *sender;
@property (nonatomic, strong) TTUser *recipient;

+ (instancetype)unreadTicWithId:(NSString*)objectId;

+ (void)fetchTicInBackgroundWithId:(NSString *)ticId timestamp:(NSDate *)fetchTimestamp completion:(void (^)(TTTic *fetchedTic, NSError *error))completion;

@end
