//
//  TTNewTic.h
//  TicText
//
//  Created by Kevin Yufei Chen on 5/3/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>

@interface TTNewTic : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *ticId;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *senderUserId;
@property (nonatomic, strong) NSString *recipientUserId;
@property (nonatomic, strong) NSDate *sendTimestamp;
@property (nonatomic, assign) NSTimeInterval timeLimit;

+ (void)retrieveNewTicsInBackgroundWithBlock:(void (^)(NSArray *receivedNewTics, NSError *error))completion;

@end
