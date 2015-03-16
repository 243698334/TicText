//
//  TTMessagesViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>

#import "TTExpirationTimer.h"
@interface TTMessagesViewController : JSQMessagesViewController <TTExpirationTimerDelegate>

@property (nonatomic, strong) UIView *expirationToolbar;

@end
