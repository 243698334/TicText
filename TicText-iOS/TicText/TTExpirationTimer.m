//
//  TTExpirationTimer.m
//  TicText
//
//  Created by Terrence K on 3/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationTimer.h"

#define kTTExpirationTimerButtonImage @"TicsTabBarIcon"

#define DataSourceKeyTitle @"title"
#define DataSourceKeyMinValue @"minval"
#define DataSourceKeyMaxValue @"maxval"
#define DataSourceKeyValueWidth @"valwidth"

@interface TTExpirationTimer ()

@property (nonatomic, strong) UILabel *expirationTimeLabel;
@property (nonatomic, strong) NSArray *dataSources;

@property (nonatomic, strong) TTExpirationPickerController *pickerController;

// Action for tapping this button.
- (void)didTapButton;

@end

@implementation TTExpirationTimer

+ (id)buttonWithDelegate:(id<TTExpirationTimerDelegate>)delegate default:(NSTimeInterval)defaultTime {
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
    
    button.dataSources = @[
        @{
            DataSourceKeyTitle: @"hour",
            DataSourceKeyMinValue: @0,
            DataSourceKeyMaxValue: @23,
            DataSourceKeyValueWidth: @1
        },
        @{
            DataSourceKeyTitle: @"minute",
            DataSourceKeyMinValue: @0,
            DataSourceKeyMaxValue: @59,
            DataSourceKeyValueWidth: @2
        },
        @{
            DataSourceKeyTitle: @"second",
            DataSourceKeyMinValue: @0,
            DataSourceKeyMaxValue: @59,
            DataSourceKeyValueWidth: @2
        },
    ];
    
    return button;
}

+ (id)buttonWithDelegate:(NSObject<TTExpirationTimerDelegate> *)delegate {
    return [self buttonWithDelegate:delegate default:10];
}

- (void)didTapButton {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [self setExpirationTime:self.expirationTime forPickerView:pickerView];
    [pickerView setBackgroundColor:kTTUIPurpleColor];
    
    [self.pickerController dismiss];
    
    self.pickerController = [[TTExpirationPickerController alloc] initWithPickerView:pickerView];
    [self.pickerController setDelegate:self];
    self.pickerController.previewLabel.text = [self stringForTimeInterval:self.expirationTime];
    [self.pickerController present];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime {
    if (_expirationTime != expirationTime) {
        _expirationTime = expirationTime;
    
        self.pickerController.previewLabel.text = [self stringForTimeInterval:expirationTime];
    }
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataSources.count;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger maxVal = [(NSNumber *)self.dataSources[component][DataSourceKeyMaxValue] integerValue];
    NSInteger minVal = [(NSNumber *)self.dataSources[component][DataSourceKeyMinValue] integerValue];
    return maxVal - minVal + 1;
}

#pragma makr - UIPickerViewDelegate
// returns width of column and height of row for each component.
/*- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
}*/

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dataSource = self.dataSources[component];
    NSInteger minVal = [(NSNumber *)dataSource[DataSourceKeyMinValue] integerValue];
    return [NSString stringWithFormat:@"%ld", minVal + row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger weight = 1;
    NSTimeInterval sum = 0;
    for (NSInteger i = (NSInteger)self.dataSources.count - 1; i >= 0; i--) {
        NSDictionary *dataSource = self.dataSources[i];
        
        NSInteger minValue = [(NSNumber *)dataSource[DataSourceKeyMinValue] integerValue];
        NSInteger maxValue = [(NSNumber *)dataSource[DataSourceKeyMaxValue] integerValue];
        NSInteger row = minValue + [pickerView selectedRowInComponent:i];
        sum += row * weight;
        
        weight *= maxValue + 1;
    }
    
    self.expirationTime = sum;
}

/*- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - TTExpirationPickerControllerDelegate
- (void)pickerControllerDidFinishPicking:(TTExpirationPickerController *)controller {
    if (controller == self.pickerController) {
        [self.delegate expirationTimer:self dismissedPickerWithExpiration:self.expirationTime];
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
        expirationTimeString = [NSString stringWithFormat:@"%@ in\n%@", headerString, [expirationArray componentsJoinedByString:@" "]];
    }
    
    return expirationTimeString;
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime forPickerView:(UIPickerView *)pickerView {
    NSInteger weight = 1;
    for (NSInteger i = (NSInteger)self.dataSources.count - 1; i >= 0; i--) {
        NSDictionary *dataSource = self.dataSources[i];
        
        NSInteger minValue = [(NSNumber *)dataSource[DataSourceKeyMinValue] integerValue];
        NSInteger maxValue = [(NSNumber *)dataSource[DataSourceKeyMaxValue] integerValue];
        NSInteger divisor = weight * (maxValue + 1);
        
        NSInteger row = ((NSInteger)expirationTime % divisor) / weight;
        if (row >= minValue) {
            expirationTime -= row * weight;
        } else {
            expirationTime = 0;
            row = minValue;
        }
        
        weight *= maxValue + 1;
        
        [pickerView selectRow:row inComponent:i animated:NO];
    }
}


@end
