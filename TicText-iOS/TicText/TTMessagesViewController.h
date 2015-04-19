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
#import "TTMessagesBubbleImage.h"
#import "TTUser.h"
#import "TTConversation.h"

@interface TTMessagesViewController : JSQMessagesViewController <UIActionSheetDelegate, TSMessageViewProtocol>

@property (nonatomic, assign) BOOL isKeyboardFirstResponder;

+ (TTMessagesViewController *)messagesViewControllerWithRecipient:(TTUser *)recipient;

+ (TTMessagesViewController *)messagesViewControllerWithConversation:(TTConversation *)conversation;

@end
