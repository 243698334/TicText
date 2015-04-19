//
//  TTConversationTableViewCell.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTConversation.h"

@interface TTConversationTableViewCell : UITableViewCell

+ (CGFloat)height;

+ (NSString *)reuseIdentifier;

- (void)updateWithConversation:(TTConversation *)conversation;

@end
