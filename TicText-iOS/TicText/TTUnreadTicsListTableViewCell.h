//
//  TTUnreadTicsTableViewCell.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/24/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTic.h"

@interface TTUnreadTicsListTableViewCell : UITableViewCell

+ (CGFloat)height;

+ (NSString *)reuseIdentifier;

- (void)updateWithUnreadTic:(TTTic *)unreadTic;

@end
