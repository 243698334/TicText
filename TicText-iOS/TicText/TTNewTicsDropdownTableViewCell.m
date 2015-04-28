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
@property (nonatomic, strong) UILabel *timeLeftLabel;

@property (nonatomic, strong) TTTic *unreadTic;

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
        
        self.timeLeftLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.timeLeftLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:self.timeLeftLabel.font.pointSize];
        self.timeLeftLabel.textColor = [UIColor whiteColor];
        self.timeLeftLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.timeLeftLabel];
        [self.contentView bringSubviewToFront:self.timeLeftLabel];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.addedConstraints) {
        [self.timeLeftLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
        [self.timeLeftLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.8];
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

- (void)updateWithUnreadTic:(TTTic *)unreadTic {
    self.unreadTic = unreadTic;
    [self updateTimeLeftLabel];
}

- (void)updateTimeLeftLabel {
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:self.unreadTic.sendTimestamp];
    NSTimeInterval timeLeft = self.unreadTic.timeLimit - timePassed;
    
    NSInteger hoursLeft = (NSInteger)(timeLeft / 3600);
    NSInteger minutesLeft = (NSInteger)(timeLeft - 3600 * hoursLeft) / 60;
    NSInteger secondsLeft = (NSInteger)(timeLeft - 3600 * hoursLeft - 60 * minutesLeft);
    
    if (timeLeft <= 0) {
        NSDate *expirationTimestamp = [NSDate dateWithTimeInterval:self.unreadTic.timeLimit sinceDate:self.unreadTic.sendTimestamp];
        NSDateFormatter *expirationTimestampFormatter = [[NSDateFormatter alloc] init];
        [expirationTimestampFormatter setDateFormat:@"h:mm a"];
        self.timeLeftLabel.text = [NSString stringWithFormat:@"expired at %@", [expirationTimestampFormatter stringFromDate:expirationTimestamp]];
    } else if (timeLeft < 60) {
        self.timeLeftLabel.text = [NSString stringWithFormat:@"%lds left", (long)secondsLeft];
    } else if (timeLeft < 60 * 60) {
        self.timeLeftLabel.text = [NSString stringWithFormat:@"%ldm %lds left", (long)minutesLeft, (long)secondsLeft];
    } else {
        self.timeLeftLabel.text = [NSString stringWithFormat:@"%ldh %ldm %lds left", hoursLeft, minutesLeft, secondsLeft];
    }
}

@end
