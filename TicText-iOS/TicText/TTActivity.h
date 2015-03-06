//
//  TTActivity.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>

@interface TTActivity : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *ticId;

@end
