//
//  TTUser.h
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "TTUserPrivateData.h"

@interface TTUser : PFUser<PFSubclassing>

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSData *profilePicture;
@property (nonatomic, strong) TTUserPrivateData *privateData;

@end