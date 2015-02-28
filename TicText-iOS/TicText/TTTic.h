//
//  TTTic.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>

@interface TTTic : PFObject<PFSubclassing>

@property (nonatomic) NSTimeInterval timeLimit;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *senderUserID;
@property (nonatomic, strong) NSString *recipientUserID;
@property (nonatomic, strong) NSDate *sendTimestamp;
@property (nonatomic, strong) NSDate *receiveTimestamp;

@end
