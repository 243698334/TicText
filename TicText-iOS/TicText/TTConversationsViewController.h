//
//  TTConversationsViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTUnreadTicsBannerView.h"
#import "TTUnreadTicsListView.h"
#import "TTComposeView.h"
#import "TTConversationTableViewCell.h"

@interface TTConversationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TTUnreadTicsBannerViewDelegate, TTUnreadTicsBannerViewDataSource, TTUnreadTicsListViewDelegate, TTUnreadTicsListViewDataSource, TTComposeViewDelegate>

- (BOOL)isMessagesViewControllerPresented;

@end
