//
//  TTComposeView.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTUser.h"

@protocol TTComposeViewDelegate <NSObject>

- (void)composeViewDidSelectContact:(TTUser *)contact anonymous:(BOOL)anonymous;

@end

@interface TTComposeView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<TTComposeViewDelegate> delegate;

@end
