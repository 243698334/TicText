//
//  TTMessagesViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <TSMessages/TSMessageView.h>
#import "TTExpirationPickerController.h"
#import "TTMessagesToolbar.h"
#import "TTMessagesBubbleImage.h"
#import "TTUser.h"

@interface TTMessagesViewController : JSQMessagesViewController <UIActionSheetDelegate, TSMessageViewProtocol, TTExpirationPickerControllerDelegate, TTMessagesToolbarDelegate>

@property (nonatomic) NSTimeInterval expirationTime;
@property (nonatomic, strong) UILabel *expirationLabel;

+ (TTMessagesViewController *)messagesViewControllerWithRecipient:(TTUser *)recipient;

@end
