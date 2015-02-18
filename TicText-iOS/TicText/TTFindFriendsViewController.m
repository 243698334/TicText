//
//  TTFindFriendsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTFindFriendsViewController.h"

@interface TTFindFriendsViewController () {
    UIImageView *_appIconImageView;
}

@end

@implementation TTFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithRed:kTTUIPurpleColorRed/255.0 green:kTTUIPurpleColorGreen/255.0 blue:kTTUIPurpleColorBlue/255.0 alpha:kTTUIPurpleColorAlpha/255.0];
    
    // TODO: Rest of the UI
    // App icon
    CGFloat appIconImageViewWidth = self.view.bounds.size.width * 0.8;
    CGFloat appIconImageViewHeight = appIconImageViewWidth;
    CGFloat appIconImageViewOriginX = (self.view.bounds.size.width - appIconImageViewWidth) / 2;
    CGFloat appIconImageViewOriginY = self.view.bounds.size.height * 0.15;
    _appIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(appIconImageViewOriginX, appIconImageViewOriginY, appIconImageViewWidth, appIconImageViewHeight)];
    _appIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _appIconImageView.image = [UIImage imageNamed:@"FindFriendsTitle"];
    [self.view addSubview:_appIconImageView];

}



@end
