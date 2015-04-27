//
//  TTUnreadTicsListSummaryView.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTNewTicsDropdownSummaryView.h"

#import <PureLayout/PureLayout.h>

@interface TTNewTicsDropdownSummaryView ()

@property (nonatomic, strong) UIView *unreadTicsView;
@property (nonatomic, strong) UILabel *unreadTicsTitleLabel;
@property (nonatomic, strong) UILabel *unreadTicsNumberLabel;

@property (nonatomic, strong) UIView *expiredTicsView;
@property (nonatomic, strong) UILabel *expiredTicsTitleLabel;
@property (nonatomic, strong) UILabel *expiredTicsNumberLabel;

@end

@implementation TTNewTicsDropdownSummaryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // all unread Tics
        self.unreadTicsView = [[UIView alloc] init];
        self.unreadTicsTitleLabel = [[UILabel alloc] init];
        self.unreadTicsNumberLabel = [[UILabel alloc] init];
        self.unreadTicsTitleLabel.textColor = [UIColor whiteColor];
        self.unreadTicsNumberLabel.textColor = [UIColor whiteColor];
        self.unreadTicsTitleLabel.textAlignment = NSTextAlignmentRight;
        self.unreadTicsNumberLabel.textAlignment = NSTextAlignmentRight;
        self.unreadTicsTitleLabel.font = [UIFont fontWithName:kTTUIDefaultFont size:self.unreadTicsTitleLabel.font.pointSize];
        self.unreadTicsNumberLabel.font = [UIFont fontWithName:kTTUIDefaultUltraLightFont size:48];
        self.unreadTicsTitleLabel.text = @"unread Tics";
        self.unreadTicsNumberLabel.text = @"0";
        [self.unreadTicsView addSubview:self.unreadTicsTitleLabel];
        [self.unreadTicsView addSubview:self.unreadTicsNumberLabel];
        [self addSubview:self.unreadTicsView];
        
        // expired unread Tics
        self.expiredTicsView = [[UIView alloc] init];
        self.expiredTicsTitleLabel = [[UILabel alloc] init];
        self.expiredTicsNumberLabel = [[UILabel alloc] init];
        self.expiredTicsTitleLabel.textColor = [UIColor whiteColor];
        self.expiredTicsNumberLabel.textColor = [UIColor whiteColor];
        self.expiredTicsTitleLabel.textAlignment = NSTextAlignmentRight;
        self.expiredTicsNumberLabel.textAlignment = NSTextAlignmentRight;
        self.expiredTicsTitleLabel.font = [UIFont fontWithName:kTTUIDefaultFont size:self.expiredTicsTitleLabel.font.pointSize];
        self.expiredTicsNumberLabel.font = [UIFont fontWithName:kTTUIDefaultUltraLightFont size:48];
        self.expiredTicsTitleLabel.text = @"expired Tics";
        self.expiredTicsNumberLabel.text = @"0";
        [self.expiredTicsView addSubview:self.expiredTicsTitleLabel];
        [self.expiredTicsView addSubview:self.expiredTicsNumberLabel];
        [self addSubview:self.expiredTicsView];
    }
    return self;
}

- (void)reloadData {
    if (self.dataSource) {
        self.unreadTicsNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.dataSource numberOfUnreadTics]];
        self.expiredTicsNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.dataSource numberOfExpiredTics]];
        if ([self.dataSource numberOfExpiredTics] == 1) {
            self.unreadTicsTitleLabel.text = @"unread Tic";
            self.expiredTicsTitleLabel.text = @"expired Tic";
        }
    }
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {

    [self.unreadTicsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.unreadTicsView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:0.5];
    
    [self.expiredTicsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.expiredTicsView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.unreadTicsView];
    
    [self.unreadTicsTitleLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.unreadTicsView];
    [self.unreadTicsTitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.unreadTicsView];
    [self.unreadTicsTitleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.unreadTicsView withMultiplier:0.25];
    [self.unreadTicsNumberLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.unreadTicsView];
    [self.unreadTicsNumberLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.unreadTicsTitleLabel];
    [self.unreadTicsNumberLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.unreadTicsView withMultiplier:0.5];
    
    [self.expiredTicsTitleLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.expiredTicsView];
    [self.expiredTicsTitleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.expiredTicsView];
    [self.expiredTicsTitleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.expiredTicsView withMultiplier:0.25];
    [self.expiredTicsNumberLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.expiredTicsView];
    [self.expiredTicsNumberLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.expiredTicsTitleLabel];
    [self.expiredTicsNumberLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.expiredTicsView withMultiplier:0.5];
    
    [super updateConstraints];
}

@end
