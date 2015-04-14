//
//  TTConversationTableViewCell.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTConversationTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDate *lastActivityTimestamp;

+ (CGFloat)height;

@end
