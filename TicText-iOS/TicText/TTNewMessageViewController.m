//
//  TTNewMessageViewController.m
//  TicText
//
//  Created by Terrence K on 3/6/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTNewMessageViewController.h"

@interface TTNewMessageViewController ()

@end

@implementation TTNewMessageViewController

+ (instancetype)messagesViewController {
    TTNewMessageViewController *viewController = [super messagesViewController];
    viewController.navigationItem.title = @"New Message";
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
