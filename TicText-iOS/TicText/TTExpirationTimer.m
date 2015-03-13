//
//  TTExpirationTimer.m
//  TicText
//
//  Created by Terrence K on 3/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationTimer.h"

#define kTTExpirationTimerButtonImage @"TicsTabBarIcon"

@interface TTExpirationTimer ()

@property (nonatomic, strong) UILabel *expirationTimeLabel;

// Action for tapping this button.
- (void)didTapButton;

@end

@implementation TTExpirationTimer

+ (id)buttonWithDelegate:(id<TTExpirationTimerDelegate>)delegate Default:(NSTimeInterval)defaultTime {
    TTExpirationTimer *button = [self buttonWithType:UIButtonTypeCustom];
    [button setDelegate:delegate];
    [button setImage:[UIImage imageNamed:kTTExpirationTimerButtonImage]
            forState:UIControlStateNormal];
    
    button.expirationTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    button.expirationTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [button.expirationTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [button.expirationTimeLabel setText:@""];
    [button addSubview:button.expirationTimeLabel];
    
    [button addTarget:button action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
    
    [button setExpirationTime:defaultTime];
    
    return button;
}

+ (id)buttonWithDelegate:(NSObject<TTExpirationTimerDelegate> *)delegate {
    return [self buttonWithDelegate:delegate Default:10];
}

- (void)didTapButton {
    [self.delegate expirationTimerDesiresNewTime:self];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime {
    _expirationTime = expirationTime;
    
    // Get the system calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *firstDate = [[NSDate alloc] init];
    NSDate *secondDate = [[NSDate alloc] initWithTimeInterval:expirationTime sinceDate:firstDate];
    
    // Get conversion to months, days, hours, minutes
    unsigned unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *conversionInfo = [calendar components:unitFlags
                                                   fromDate:firstDate
                                                     toDate:secondDate
                                                    options:0];
    
    NSString *expirationTimeString = [NSString stringWithFormat:@"%ldd %ldh %ldm %lds", [conversionInfo day],
                                      [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
    
    NSLog(@"TTExpirationTimer (setExpirationTime:): set label to %@", expirationTimeString);
    
    self.expirationTimeLabel.text = expirationTimeString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
