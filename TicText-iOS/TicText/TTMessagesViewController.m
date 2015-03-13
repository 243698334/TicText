//
//  TTMessagesViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesViewController.h"
#import "TTUser.h"
#import "TTExpirationTimer.h"

@interface TTMessagesViewController ()

@end

@implementation TTMessagesViewController

+ (instancetype)messagesViewController {
    TTMessagesViewController *viewController = [super messagesViewController];
    
    viewController.view.backgroundColor = [UIColor grayColor];
    viewController.navigationItem.title = @"Some Dialog";
    viewController.hidesBottomBarWhenPushed = YES;
    
    UIButton *expirationTimerButton = [TTExpirationTimer buttonWithDelegate:viewController];
    viewController.inputToolbar.contentView.leftBarButtonItem = expirationTimerButton;
    
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.senderId = @"fake_sender_id";
    self.senderDisplayName = [[TTUser currentUser] displayName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTExpirationTimerDelegate
- (void)expirationTimerDesiresNewTime:(TTExpirationTimer *)expirationTimer {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
