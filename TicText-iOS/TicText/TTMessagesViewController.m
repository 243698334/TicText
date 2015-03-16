//
//  TTMessagesViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesViewController.h"
#import "TTUser.h"

#define kDefaultExpirationTime 3600

@interface JSQMessagesViewController (PrivateMethods)

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;

@end

@interface TTMessagesViewController ()

@property (nonatomic, strong) TTExpirationTimer *expirationTimer;
@property (nonatomic, strong) UILabel *expirationLabel;

@end

@implementation TTMessagesViewController

+ (instancetype)messagesViewController {
    TTMessagesViewController *viewController = [super messagesViewController];
    
    viewController.view.backgroundColor = [UIColor grayColor];
    viewController.navigationItem.title = @"Some Dialog";
    viewController.hidesBottomBarWhenPushed = YES;
    
    viewController.expirationTimer = [TTExpirationTimer buttonWithDelegate:viewController];
    viewController.expirationTimer.expirationTime = kDefaultExpirationTime;
    viewController.inputToolbar.contentView.leftBarButtonItem = viewController.expirationTimer;
    
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.senderId = @"fake_sender_id";
    self.senderDisplayName = [[TTUser currentUser] displayName];
    
    [self setupExpirationToolbar];
}

#define kExpirationToolbarHeight 44.0f
#define kExpirationToolbarAlpha 0.60f
- (CGRect)expirationToolbarFrame {
    return CGRectMake(0, self.inputToolbar.frame.origin.y - kExpirationToolbarHeight,
                      self.inputToolbar.frame.size.width, kExpirationToolbarHeight);
}

- (void)setupExpirationToolbar {
    self.expirationToolbar = [[UIView alloc] initWithFrame:[self expirationToolbarFrame]];
    [self.expirationToolbar setAlpha:kExpirationToolbarAlpha];
    
    self.expirationLabel = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.expirationToolbar.frame.size.width, self.expirationToolbar.frame.size.height), 8.0f, 8.0f)];
    [self.expirationLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.expirationLabel setText:[self stringForTimeInterval:kDefaultExpirationTime]];
    [self.expirationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.expirationLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.expirationToolbar addSubview:self.expirationLabel];
    
    [self.view addSubview:self.expirationToolbar];
}

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant {
    [super jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant];
    
    [self.expirationToolbar setFrame:[self expirationToolbarFrame]];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    
}

#pragma mark - TTExpirationTimerDelegate
- (void)expirationTimer:(TTExpirationTimer *)expirationTimer dismissedPickerWithExpiration:(NSTimeInterval)expiration {
    if (expirationTimer == self.expirationTimer) {
        self.expirationLabel.text = [self stringForTimeInterval:expiration];
    }
}

#pragma mark - Helpers
- (NSString *)stringForTimeInterval:(NSTimeInterval)interval {
    // Get the system calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *firstDate = [[NSDate alloc] init];
    NSDate *secondDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:firstDate];
    
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *conversionInfo = [calendar components:unitFlags
                                                   fromDate:firstDate
                                                     toDate:secondDate
                                                    options:0];
    
    NSString *expirationTimeString = nil;
    NSString *headerString = @"Your Tic will expire";
    
    NSMutableArray *expirationArray = [NSMutableArray array];
    if ([conversionInfo hour] != 0) {
        NSString *hourUnit = ([conversionInfo hour] == 1) ? @"hour" : @"hours";
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", [conversionInfo hour], hourUnit]];
    }
    if ([conversionInfo minute] != 0) {
        NSString *minuteUnit = ([conversionInfo minute] == 1) ? @"min" : @"mins";
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", [conversionInfo minute], minuteUnit]];
    }
    if ([conversionInfo second] != 0) {
        NSString *secondUnit = ([conversionInfo second] == 1) ? @"sec" : @"secs";
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", [conversionInfo second], secondUnit]];
    }
    if (expirationArray.count == 0) {
        expirationTimeString = [NSString stringWithFormat:@"%@ %@", headerString, @"instantly"];
    } else {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@", headerString, [expirationArray componentsJoinedByString:@" "]];
    }

    return expirationTimeString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
