//
//  TTConversationTableViewCell.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConversationTableViewCell.h"

@implementation TTConversationTableViewCell

+ (CGFloat)height {
    return 60;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])){
        self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    }
    return self;
}

- (void)prepareForReuse {
    for (UIView *subview in [self.accessoryView subviews]) {
        [subview removeFromSuperview];
    }
}

- (void)layoutSubviews {
    for (UIView *subview in [self.accessoryView subviews]) {
        [subview removeFromSuperview];
    }
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(5, 5, 48, 48);
    
    CGRect tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x = 58;
    tmpFrame.origin.y = 5;
    self.textLabel.frame = tmpFrame;
    
    tmpFrame = self.detailTextLabel.frame;
    tmpFrame.origin.x = 58;
    self.detailTextLabel.frame = tmpFrame;
    
    UILabel *lastTicTimestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 15)];
    lastTicTimestampLabel.font = [UIFont systemFontOfSize:10];
    lastTicTimestampLabel.textAlignment = NSTextAlignmentCenter;
    
    NSTimeInterval secondsSinceLastTic = [[NSDate date] timeIntervalSinceDate:self.lastActivityTimestamp];
    unsigned dateComponentsFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *todaysDateComponents = [[NSCalendar currentCalendar] components:dateComponentsFlags fromDate:[NSDate date]];
    NSDateComponents *lastTicDateComponents = [[NSCalendar currentCalendar] components:dateComponentsFlags fromDate:self.lastActivityTimestamp];
    NSDateFormatter *lastTicTimestampFormatter = [[NSDateFormatter alloc] init];
    
    BOOL lastTicIsToday = [todaysDateComponents month] == [lastTicDateComponents month] && [todaysDateComponents day] == [lastTicDateComponents day] && [todaysDateComponents year] == [lastTicDateComponents year];
    
    if (lastTicIsToday) {
        if (secondsSinceLastTic < 60) {
            // show "just now" for last Tic within one minute
            lastTicTimestampLabel.text = @"Just now";
        } else if (secondsSinceLastTic >= 60 && secondsSinceLastTic < 3600) {
            // show minutes passed for last Tic within one hour
            lastTicTimestampLabel.text = [NSString stringWithFormat:@"%lumin ago", (NSUInteger)secondsSinceLastTic / 60 + 1];
        } else {
            // show "h:mm a" for last Tic within same day
            [lastTicTimestampFormatter setDateFormat:@"h:mm a"];
            [lastTicTimestampFormatter setDoesRelativeDateFormatting:NO];
            lastTicTimestampLabel.text = [lastTicTimestampFormatter stringFromDate:self.lastActivityTimestamp];
        }
    } else {
        [lastTicTimestampFormatter setDateStyle:NSDateFormatterMediumStyle];
        [lastTicTimestampFormatter setDoesRelativeDateFormatting:YES];
        NSString *lastTicDateString = [lastTicTimestampFormatter stringFromDate:self.lastActivityTimestamp];
        if ([lastTicDateString isEqualToString:@"Yesterday"]) {
            // show "Yesterday" for last Tic of yesterday
            lastTicTimestampLabel.text = @"Yesterday";
        } else {
            // show date for last Tic before yesterday
            [lastTicTimestampFormatter setDateFormat:@"MMM d"];
            [lastTicTimestampFormatter setDoesRelativeDateFormatting:NO];
            lastTicTimestampLabel.text = [lastTicTimestampFormatter stringFromDate:self.lastActivityTimestamp];
        }
    }
    
    [self.accessoryView addSubview:lastTicTimestampLabel];
}


@end
