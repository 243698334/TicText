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

@interface TTConversationsViewController ()

@property (nonatomic, strong)MBProgressHUD *progressHUD;

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"TicText";

    [self setupDevButtons];
}

- (void)setupDevButtons {
    UIButton *chatWithKevinDevButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chatWithKevinDevButton addTarget:self action:@selector(chatWithKevinDev) forControlEvents:UIControlEventTouchUpInside];
    [chatWithKevinDevButton setTitle:@"Chat with KevinDev" forState:UIControlStateNormal];
    chatWithKevinDevButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.2, [UIScreen mainScreen].bounds.size.height * 0.4, [UIScreen mainScreen].bounds.size.width * 0.5, 44);
    [self.view addSubview:chatWithKevinDevButton];
    
    UIButton *chatWithKevinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chatWithKevinButton addTarget:self action:@selector(chatWithKevin) forControlEvents:UIControlEventTouchUpInside];
    [chatWithKevinButton setTitle:@"Chat with Kevin" forState:UIControlStateNormal];
    chatWithKevinButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.2, [UIScreen mainScreen].bounds.size.height * 0.5, [UIScreen mainScreen].bounds.size.width * 0.5, 44);
    [self.view addSubview:chatWithKevinButton];
    
    UIButton *chatWithCKDevButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chatWithCKDevButton addTarget:self action:@selector(chatWithCKDev) forControlEvents:UIControlEventTouchUpInside];
    [chatWithCKDevButton setTitle:@"Chat with CKDev" forState:UIControlStateNormal];
    chatWithCKDevButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.2, [UIScreen mainScreen].bounds.size.height * 0.6, [UIScreen mainScreen].bounds.size.width * 0.5, 44);
    [self.view addSubview:chatWithCKDevButton];
    
    UIButton *chatWithCKButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chatWithCKButton addTarget:self action:@selector(chatWithCK) forControlEvents:UIControlEventTouchUpInside];
    [chatWithCKButton setTitle:@"Chat with CK" forState:UIControlStateNormal];
    chatWithCKButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.2, [UIScreen mainScreen].bounds.size.height * 0.7, [UIScreen mainScreen].bounds.size.width * 0.5, 44);
    [self.view addSubview:chatWithCKButton];
}

- (void)chatWithKevinDev {
    NSString *kevinDevId = @"F8ekXoLCGN";
    TTUser *kevinDev = [TTUser objectWithoutDataWithObjectId:kevinDevId];
    [self presentMessagesViewControllerWithRecipient:kevinDev];
    
}

- (void)chatWithKevin {
    NSString *kevinId = @"4ynJPt9u9w";
    TTUser *kevin = [TTUser objectWithoutDataWithObjectId:kevinId];
    [self presentMessagesViewControllerWithRecipient:kevin];
}

- (void)chatWithCKDev {
    NSString *ckDevId = @"YlnkEyAQyF";
    TTUser *ckDev = [TTUser objectWithoutDataWithObjectId:ckDevId];
    [self presentMessagesViewControllerWithRecipient:ckDev];
}

- (void)chatWithCK {
    NSString *ckId = @"9vre9oQlWh";
    TTUser *ck = [TTUser objectWithoutDataWithObjectId:ckId];
    [self presentMessagesViewControllerWithRecipient:ck];
}

- (void)presentMessagesViewControllerWithRecipient:(TTUser *)recipient {
    [recipient fetchFromLocalDatastoreInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [recipient fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self.progressHUD removeFromSuperview];
                TTUser *fetchedRecipient = (TTUser *)object;
                TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewControllerWithRecipient:fetchedRecipient];
                messagesViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:messagesViewController animated:YES];
            }];
        } else {
            TTUser *fetchedRecipient = (TTUser *)object;
            TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewControllerWithRecipient:fetchedRecipient];
            messagesViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:messagesViewController animated:YES];
        }
    }];
}

@end
