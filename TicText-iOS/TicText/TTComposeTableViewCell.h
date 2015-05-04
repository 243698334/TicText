//
//  TTComposeTableViewCell.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTUser.h"

@interface TTComposeTableViewCell : UITableViewCell

+ (CGFloat)height;

+ (NSString *)reuseIdentifier;

- (void)updateWithUser:(TTUser *)user;

@end
