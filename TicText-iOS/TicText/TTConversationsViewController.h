//
//  TTConversationsViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTScrollToTopView.h"
#import "TTUnreadTicsView.h"
#import "TTComposeView.h"
#import "TTConversationTableViewCell.h"

@interface TTConversationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TTScrollToTopViewDelegate, TTUnreadTicsViewDelegate, TTComposeViewDelegate>

@end
