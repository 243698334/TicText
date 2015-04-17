//
//  TTContactTableViewCell.h
//  TicText
//
//  Created by Jack Arendt on 4/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTUser.h"

@interface TTContactTableViewCell : UITableViewCell

@property (nonatomic, strong) TTUser *user;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *createTicButtton;

@property (nonatomic) BOOL createTicVisible;
@end
