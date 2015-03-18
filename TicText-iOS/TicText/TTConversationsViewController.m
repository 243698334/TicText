//
//  TTConversationsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConversationsViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "TTMessagesViewController.h"
#import "TTUser.h"

@interface TTConversationsViewController () {
    NSNumber *devButtonCount;
    NSMutableDictionary *devFriendsDictionary;
    NSMutableDictionary *devButtonsDictionary;
}

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"TicText";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupDevButtons];
}

- (void)setupDevButtons {
    NSArray *devButtonsKeys = [devButtonsDictionary allKeys];
    for (NSNumber *devButtonKey in devButtonsKeys) {
        UIButton *devButton = [devButtonsDictionary objectForKey:devButtonKey];
        [devButton removeFromSuperview];
    }
    
    devButtonCount = [NSNumber numberWithInteger:0];
    devFriendsDictionary = [[NSMutableDictionary alloc] init];
    devButtonsDictionary = [[NSMutableDictionary alloc] init];
    
    PFQuery *localFriendsQuery = [TTUser query];
    [localFriendsQuery fromLocalDatastore];
    [localFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (TTUser *currentFriend in objects) {
            [self setupDevChatButton:currentFriend];
        }
    }];
}

- (void)setupDevChatButton:(TTUser *)user {
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    chatButton.tag = [devButtonCount integerValue];
    [chatButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [chatButton setTitle:[NSString stringWithFormat:@"Chat with %@", user.displayName] forState:UIControlStateNormal];
    chatButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.2,
                                  [UIScreen mainScreen].bounds.size.height * (0.25 + 0.05 * devButtonCount.integerValue),
                                  [UIScreen mainScreen].bounds.size.width * 0.5, 44);
    [self.view addSubview:chatButton];
    [devFriendsDictionary setObject:user forKey:devButtonCount];
    [devButtonsDictionary setObject:chatButton forKey:devButtonCount];
    devButtonCount = [NSNumber numberWithInteger:devButtonCount.integerValue + 1];
}

- (void)buttonTapped:(UIButton *)button {
    NSNumber *devFriendKey = [NSNumber numberWithInteger:button.tag];
    TTUser *currentFriend = [devFriendsDictionary objectForKey:devFriendKey];
    TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewControllerWithRecipient:currentFriend];
    messagesViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messagesViewController animated:YES];
}

@end
