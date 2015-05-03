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
#import "TTScrollingImagePickerView.h"
#import "TTUser.h"
#import "TTTic.h"

#define kDefaultExpirationTime      3600
#define kMessagesToolbarHeight      44.0f

@interface TTMessagesViewController : JSQMessagesViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TSMessageViewProtocol, TTMessagesToolbarDelegate, TTScrollingImagePickerViewDelegate>

@property (nonatomic, strong) TTMessagesToolbar *messagesToolbar;
@property (nonatomic, strong) UIView *toolbarContentView;

@property (nonatomic, strong) TTUser *recipient;
@property (nonatomic) NSTimeInterval expirationTime;
@property (nonatomic) BOOL isAnonymous;

+ (TTMessagesViewController *)messagesViewControllerWithRecipient:(TTUser *)recipient;
- (void)timerIsZero:(NSDate *)timestamp;
- (TTTic *)ticWithMessage:(JSQMessage *)message mediaFile:(PFFile *)mediaFile;
- (void)deselectCurrentToolbarItem;

@end
