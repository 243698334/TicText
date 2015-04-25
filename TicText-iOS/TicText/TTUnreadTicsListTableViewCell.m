//
//  TTUnreadTicsTableViewCell.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/24/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTUnreadTicsListTableViewCell.h"

#import <PureLayout/PureLayout.h>

@interface TTUnreadTicsListTableViewCell ()

@property (nonatomic, assign) BOOL addedConstraints;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) TTTic *unreadTic;

@end

CGFloat const kTTUnreadTicsListTableViewCellHeight = 40;
CGFloat const kTTUnreadTicsListTableViewCellPadding = 3;

@implementation TTUnreadTicsListTableViewCell

+ (CGFloat)height {
    return kTTUnreadTicsListTableViewCellHeight;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.addedConstraints = NO;
        
        self.timerLabel = [[UILabel alloc] init];
        self.timerLabel.font = [UIFont fontWithName:@"Avenir-Light" size:self.timerLabel.font.pointSize];
        self.timerLabel.textColor = [UIColor whiteColor];
        self.timerLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timerLabel];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.addedConstraints) {
        [self.timerLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kTTUnreadTicsListTableViewCellPadding, kTTUnreadTicsListTableViewCellPadding, kTTUnreadTicsListTableViewCellPadding, kTTUnreadTicsListTableViewCellPadding) excludingEdge:ALEdgeLeading];
        
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

- (void)updateWithUnreadTic:(TTTic *)unreadTic {
    self.unreadTic = unreadTic;
    if (self.timer != nil) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeftLabel) userInfo:nil repeats:YES];
}

- (void)updateTimeLeftLabel {
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:self.unreadTic.sendTimestamp];
    NSTimeInterval timeLeft = self.unreadTic.timeLimit - timePassed;
    
    NSInteger hoursLeft = (NSInteger)(timeLeft / 3600);
    NSInteger minutesLeft = (NSInteger)(timeLeft - 3600 * hoursLeft) / 60;
    NSInteger secondsLeft = (NSInteger)(timeLeft - 3600 * hoursLeft - 60 * minutesLeft);
    
    if (timeLeft <= 0) {
        self.timerLabel.text = @"expired";
    } else if (timeLeft < 60) {
        self.timerLabel.text = [NSString stringWithFormat:@"%lds", secondsLeft];
    } else if (timeLeft < 60 * 60) {
        self.timerLabel.text = [NSString stringWithFormat:@"%ldm %lds", minutesLeft, secondsLeft];
    } else {
        self.timerLabel.text = [NSString stringWithFormat:@"%ldh %ldm %lds", hoursLeft, minutesLeft, secondsLeft];
    }
}

@end
