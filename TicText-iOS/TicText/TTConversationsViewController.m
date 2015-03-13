//
//  TTConversationsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConversationsViewController.h"
#import "TTMessagesViewController.h"

@interface TTConversationsViewController ()

@end

@implementation TTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"TicText";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(newTic)];
}

- (void)newTic {
    TTMessagesViewController *newMessageViewController = [TTMessagesViewController messagesViewController];
    [self.navigationController pushViewController:newMessageViewController animated:YES];
}

- (void)presentTestViewController {
    UIViewController *testViewController = [TTMessagesViewController messagesViewController];
    testViewController.view.backgroundColor = [UIColor grayColor];
    testViewController.navigationItem.title = @"Some Dialog";
    testViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:testViewController animated:YES];
}

@end
