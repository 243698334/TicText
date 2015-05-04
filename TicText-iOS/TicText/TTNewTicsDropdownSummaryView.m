//
//  TTUnreadTicsListSummaryView.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTNewTicsDropdownSummaryView.h"

#import <PureLayout/PureLayout.h>
#import "TTNewTicsDropdownTableViewCell.h"

@interface TTNewTicsDropdownSummaryView ()

@property (nonatomic, assign) BOOL addedConstraintsForLandscapeView;
@property (nonatomic, assign) BOOL addedConstraintsForPortraitView;

@property (nonatomic, strong) UILabel *unreadTicsTitleLabel;
@property (nonatomic, strong) UILabel *unreadTicsNumberLabel;

@property (nonatomic, strong) UILabel *expiredTicsTitleLabel;
@property (nonatomic, strong) UILabel *expiredTicsNumberLabel;

@end

CGFloat const kNewTicsDropdownSummaryViewLandscapeHeight = 90;
CGFloat const kNewTicsDropDownSummaryViewPortraitHeight = 180;

@implementation TTNewTicsDropdownSummaryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // all unread Tics
        //self.unreadTicsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height / 2)];

        
        // expired unread Tics
        self.expiredTicsNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5 * (1 + 0.25), self.frame.size.width, self.frame.size.height * 0.5 * 0.5)];
        self.expiredTicsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5 * (1 + 0.75), self.frame.size.width, self.frame.size.height * 0.5 * 0.25)];
        self.expiredTicsNumberLabel.textColor = [UIColor whiteColor];
        self.expiredTicsTitleLabel.textColor = [UIColor whiteColor];
        self.expiredTicsNumberLabel.textAlignment = NSTextAlignmentRight;
        self.expiredTicsTitleLabel.textAlignment = NSTextAlignmentRight;
        self.expiredTicsNumberLabel.font = [UIFont fontWithName:kTTUIDefaultUltraLightFont size:48];
        self.expiredTicsTitleLabel.font = [UIFont fontWithName:kTTUIDefaultFont size:self.expiredTicsTitleLabel.font.pointSize];
        [self addSubview:self.expiredTicsNumberLabel];
        [self addSubview:self.expiredTicsTitleLabel];
        
        self.unreadTicsNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5 * 0.25, self.frame.size.width, self.frame.size.height * 0.5 * 0.5)];
        self.unreadTicsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.5 * 0.75, self.frame.size.width, self.frame.size.height * 0.5 * 0.25)];
        self.unreadTicsNumberLabel.textColor = [UIColor whiteColor];
        self.unreadTicsTitleLabel.textColor = [UIColor whiteColor];
        self.unreadTicsNumberLabel.textAlignment = NSTextAlignmentRight;
        self.unreadTicsTitleLabel.textAlignment = NSTextAlignmentRight;
        self.unreadTicsNumberLabel.font = [UIFont fontWithName:kTTUIDefaultUltraLightFont size:48];
        self.unreadTicsTitleLabel.font = [UIFont fontWithName:kTTUIDefaultFont size:self.unreadTicsTitleLabel.font.pointSize];
        [self addSubview:self.unreadTicsNumberLabel];
        [self addSubview:self.unreadTicsTitleLabel];
        
        // show portrait layout by default
        self.isShowingLandscapeLayout = NO;
        self.addedConstraintsForLandscapeView = NO;
        self.addedConstraintsForPortraitView = NO;
    }
    return self;
}

- (void)updateFrames {
    if (self.isShowingLandscapeLayout) {
        CGRect unreadTicsNumberLabelFrame = self.unreadTicsNumberLabel.frame;
        unreadTicsNumberLabelFrame.origin.x = self.bounds.size.width * 0.1;
        
        CGRect unreadTicsTitleLabelFrame = self.unreadTicsTitleLabel.frame;
        unreadTicsTitleLabelFrame.origin.x = self.bounds.size.width * 0.1;

        CGRect expiredTicsNumberLabelFrame = self.expiredTicsNumberLabel.frame;
        expiredTicsNumberLabelFrame.origin.x = self.bounds.size.width * 0.6;
        expiredTicsNumberLabelFrame.origin.y = self.bounds.size.height * 0.25;
        
        CGRect expiredTicsTitleLabelFrame = self.expiredTicsTitleLabel.frame;
        expiredTicsTitleLabelFrame.origin.x = self.bounds.size.width * 0.6;
        expiredTicsTitleLabelFrame.origin.y = self.bounds.size.height * 0.75;
        
        self.unreadTicsNumberLabel.frame = unreadTicsNumberLabelFrame;
        self.unreadTicsTitleLabel.frame = unreadTicsTitleLabelFrame;
        self.expiredTicsNumberLabel.frame = expiredTicsNumberLabelFrame;
        self.expiredTicsTitleLabel.frame = expiredTicsTitleLabelFrame;
        
        self.expiredTicsNumberLabel.textAlignment = NSTextAlignmentLeft;
        self.expiredTicsTitleLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        CGRect unreadTicsNumberLabelFrame = self.unreadTicsNumberLabel.frame;
        unreadTicsNumberLabelFrame.origin.x = 0;
        
        CGRect unreadTicsTitleLabelFrame = self.unreadTicsTitleLabel.frame;
        unreadTicsTitleLabelFrame.origin.x = 0;
        
        CGRect expiredTicsNumberLabelFrame = self.expiredTicsNumberLabel.frame;
        expiredTicsNumberLabelFrame.origin.x = 0;
        expiredTicsNumberLabelFrame.origin.y = self.frame.size.height * 0.5 * (1 + 0.25);
        
        CGRect expiredTicsTitleLabelFrame = self.expiredTicsTitleLabel.frame;
        expiredTicsTitleLabelFrame.origin.x = 0;
        expiredTicsTitleLabelFrame.origin.y = self.frame.size.height * 0.5 * (1 + 0.75);
        
        self.unreadTicsNumberLabel.frame = unreadTicsNumberLabelFrame;
        self.unreadTicsTitleLabel.frame = unreadTicsTitleLabelFrame;
        self.expiredTicsNumberLabel.frame = expiredTicsNumberLabelFrame;
        self.expiredTicsTitleLabel.frame = expiredTicsTitleLabelFrame;
        
        self.expiredTicsNumberLabel.textAlignment = NSTextAlignmentRight;
        self.expiredTicsTitleLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)reloadData {
    if (self.dataSource) {
        self.unreadTicsNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.dataSource numberOfUnreadTics]];
        self.expiredTicsNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.dataSource numberOfExpiredTics]];
        self.unreadTicsTitleLabel.text = [NSString stringWithFormat:@"unread Tic%@", [self.dataSource numberOfUnreadTics] == 1 ? @"" : @"s"];
        self.expiredTicsTitleLabel.text = [NSString stringWithFormat:@"expired Tic%@", [self.dataSource numberOfExpiredTics] == 1 ? @"" : @"s"];
    }
    [self setNeedsUpdateConstraints];
}

@end
