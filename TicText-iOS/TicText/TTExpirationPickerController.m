//
//  TTPickerContainer.m
//  TicText
//
//  Created by Terrence K on 3/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationPickerController.h"
#import "TTExpirationDomain.h"

#define HEADER_HEIGHT (66.0f)
#define PICKER_HEIGHT (216.0f)
#define VIEW_HEIGHT (HEADER_HEIGHT + PICKER_HEIGHT)
#define VIEW_WIDTH (self.frame.size.width)

#define BACKGROUND_ALPHA (0.8)
#define PRESENTATION_DURATION (0.33)
#define DISMISS_DURATION PRESENTATION_DURATION

@interface TTExpirationPickerController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UILabel *previewLabel;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSArray *expirationUnits;

@property (nonatomic) NSTimeInterval expirationTime;

@end

@implementation TTExpirationPickerController

- (id)initWithExpirationTime:(NSTimeInterval)expirationTime {
    if (self = [super init]) {
        self.expirationTime = expirationTime;
        self.expirationUnits = [TTExpirationDomain expirationUnits];
        
        UIWindow *frontWindow = [self frontWindow];
        self.frame = CGRectMake(0, 0,
                                frontWindow.frame.size.width, VIEW_HEIGHT);
        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        [self.pickerView setBackgroundColor:kTTUIPurpleColor];
        
        [self setupHeaderView];
        [self setupPickerView];
    }
    return self;
}

- (void)setupHeaderView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEADER_HEIGHT)];
    [self.headerView setBackgroundColor:[UIColor whiteColor]];
    [self.headerView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin |  UIViewAutoresizingFlexibleWidth];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1.5)];
    [lineView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    [lineView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    [self.headerView addSubview:lineView];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [dismissButton setTitle:@"Done" forState:UIControlStateNormal];
    [dismissButton sizeToFit];
    [dismissButton setFrame:CGRectMake(self.headerView.frame.size.width - (dismissButton.frame.size.width + 16.0), 0, dismissButton.frame.size.width + 16.0, self.headerView.frame.size.height)];
    [dismissButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:dismissButton];
    
    self.previewLabel = [[UILabel alloc] init];
    [self.previewLabel setText:@"---"];
    [self.previewLabel setNumberOfLines:2];
    [self.previewLabel setFrame:CGRectMake(8.0f, 8.0f, dismissButton.frame.origin.x - 16.0,
                                           HEADER_HEIGHT - 16.0)];
    [self.previewLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [self.headerView addSubview:self.previewLabel];
    
    [self addSubview:self.headerView];
}

- (void)setupPickerView {
    [self.pickerView setFrame:CGRectMake(0.0, HEADER_HEIGHT, self.frame.size.width, PICKER_HEIGHT)];
    
    [self addSubview:self.pickerView];
    
    [self setupDefaultValues];
}

- (void)setupDefaultValues {
    [TTExpirationDomain setUnits:self.expirationUnits forExpirationTime:self.expirationTime];
    
    for (NSInteger i = 0; i < self.expirationUnits.count; i++) {
        TTExpirationUnit *unit = self.expirationUnits[i];
        [self.pickerView selectRow:(unit.currentValue.integerValue - unit.minValue.integerValue)
                       inComponent:i
                          animated:NO];
    }
    
    [self refreshPreviewLabel];
}

- (void)refreshPreviewLabel {
    self.previewLabel.text = [TTExpirationDomain stringForTimeInterval:self.expirationTime];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime {
    if (_expirationTime != expirationTime) {
        _expirationTime = expirationTime;
        
        [self refreshPreviewLabel];
    }
}

- (void)present {
    // Removing existing background view if one is already being shown
    [self.backgroundView removeFromSuperview];
    
    UIWindow *frontWindow = [self frontWindow];
    
    // Arrange background view
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   frontWindow.frame.size.width,
                                                                   frontWindow.frame.size.height)];
    [self.backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.backgroundView setAlpha:0];
    [frontWindow addSubview:self.backgroundView];
    [frontWindow bringSubviewToFront:self.backgroundView];
    
    // Arrange ourselves
    [self setFrame:CGRectMake(0, frontWindow.frame.size.height, VIEW_WIDTH, VIEW_HEIGHT)];
    [frontWindow addSubview:self];
    [frontWindow bringSubviewToFront:self];
    
    [UIView animateWithDuration:PRESENTATION_DURATION animations:^{
        [self.backgroundView setAlpha:BACKGROUND_ALPHA];
        [self setFrame:CGRectMake(0, frontWindow.frame.size.height - VIEW_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT)];
    }];
}

- (void)dismiss {
    [self.delegate pickerController:self didFinishWithExpiration:self.expirationTime];
    
    UIWindow *frontWindow = [self frontWindow];
    
    [UIView animateWithDuration:DISMISS_DURATION animations:^{
        [self.backgroundView setAlpha:0];
        [self setFrame:CGRectMake(0, frontWindow.frame.size.height, VIEW_WIDTH, VIEW_HEIGHT)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Helper Methods
- (UIWindow *)frontWindow {
    return [[[UIApplication sharedApplication] windows] lastObject];
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.expirationUnits.count;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    TTExpirationUnit *unit = self.expirationUnits[component];
    return unit.maxValue.integerValue - unit.minValue.integerValue + 1;
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
    TTExpirationUnit *unit = self.expirationUnits[component];
    return [NSString stringWithFormat:@"%ld", unit.minValue.integerValue + row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    TTExpirationUnit *unit = self.expirationUnits[component];
    unit.currentValue = [NSNumber numberWithInteger:(unit.minValue.integerValue + row)];
    self.expirationTime = [TTExpirationDomain expirationTimeFromUnits:self.expirationUnits];
}

/*- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
 
 }*/

@end
