//
//  TTUnreadTicsTableViewCell.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/24/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTNewTicsDropdownTableViewCell.h"

#import <PureLayout/PureLayout.h>

@interface TTNewTicsDropdownTableViewCell ()

@property (nonatomic, assign) BOOL addedConstraints;
@property (nonatomic, strong) UIImageView *bulletImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

CGFloat const kTTUnreadTicsListTableViewCellHeight = 36;
CGFloat const kTTUnreadTicsListTableViewCellPadding = 3;

@implementation TTNewTicsDropdownTableViewCell

+ (CGFloat)height {
    return kTTUnreadTicsListTableViewCellHeight;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.addedConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.bulletImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.bulletImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:self.titleLabel.font.pointSize];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView bringSubviewToFront:self.titleLabel];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.addedConstraints) {
        [self.bulletImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView];
        [self.bulletImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.bulletImageView];
        
        [self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
        [self.titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.8];
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

- (void)updateCellWithSendTimestamp:(NSDate *)sendTimestamp timeLimit:(NSTimeInterval)timeLimit {
    [self updateTitleLabelWithSendTimestamp:sendTimestamp timeLimit:timeLimit];
    [self updateAccessoryViewWithSendTimestamp:sendTimestamp timeLimit:timeLimit];
}

- (void)updateCellWithNumberOfTicsFromSameSender:(NSInteger)numberOfNewTics {
    [self updateTitleLabelWithNumberOfTicsFromSameSender:numberOfNewTics];
    [self updateAccessoryViewWithNumberOfTicsFromSameSender:numberOfNewTics];
}


- (void)updateTitleLabelWithSendTimestamp:(NSDate *)sendTimestamp timeLimit:(NSTimeInterval)timeLimit {
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:sendTimestamp];
    NSTimeInterval timeLeft = timeLimit - timePassed;
    
    NSInteger hoursLeft = (NSInteger)(timeLeft / 3600);
    NSInteger minutesLeft = (NSInteger)(timeLeft - 3600 * hoursLeft) / 60;
    NSInteger secondsLeft = (NSInteger)(timeLeft - 3600 * hoursLeft - 60 * minutesLeft);
    
    if (timeLeft <= 0) {
        NSDate *expirationTimestamp = [NSDate dateWithTimeInterval:timeLimit sinceDate:sendTimestamp];
        NSDateFormatter *expirationTimestampFormatter = [[NSDateFormatter alloc] init];
        [expirationTimestampFormatter setDateFormat:@"h:mm a"];
        self.titleLabel.text = [NSString stringWithFormat:@"expired at %@", [expirationTimestampFormatter stringFromDate:expirationTimestamp]];
        self.titleLabel.textColor = [UIColor lightGrayColor];
    } else if (timeLeft < 60) {
        self.titleLabel.text = [NSString stringWithFormat:@"%lis left", secondsLeft];
    } else if (timeLeft < 60 * 60) {
        self.titleLabel.text = [NSString stringWithFormat:@"%lim %lis left", minutesLeft, secondsLeft];
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"%lih %lim %lis left", hoursLeft, minutesLeft, secondsLeft];
    }
}

- (void)updateTitleLabelWithNumberOfTicsFromSameSender:(NSInteger)numberOfNewTics {
    self.titleLabel.text = [NSString stringWithFormat:@"%li Tic%@ from same sender", numberOfNewTics, numberOfNewTics > 1 ? @"s" : @""];
}

- (void)updateAccessoryViewWithSendTimestamp:(NSDate *)sendTimestamp timeLimit:(NSTimeInterval)timeLimit {
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:sendTimestamp];
    NSTimeInterval timeLeft = timeLimit - timePassed;
    
    if (timeLeft <= 0) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewTicsDropdownTableViewCellAccessoryViewIconExpired"]];
    } else {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewTicsDropdownTableViewCellAccessoryViewIconUnread"]];
    }
}

- (void)updateAccessoryViewWithNumberOfTicsFromSameSender:(NSInteger)numberOfNewTics {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
