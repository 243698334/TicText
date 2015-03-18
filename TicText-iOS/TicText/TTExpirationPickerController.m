//
//  TTPickerContainer.m
//  TicText
//
//  Created by Terrence K on 3/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationPickerController.h"
#import "TTExpirationDomain.h"

#import "TTExpirationPickerCell.h"

#define HEADER_HEIGHT (66.0f)
#define PICKER_HEIGHT (216.0f)
#define VIEW_HEIGHT (HEADER_HEIGHT + PICKER_HEIGHT)
#define VIEW_WIDTH (self.frame.size.width)

#define BACKGROUND_ALPHA (0.8)
#define PRESENTATION_DURATION (0.33)
#define DISMISS_DURATION (1.5 * PRESENTATION_DURATION)

@interface TTExpirationPickerController ()

@property (nonatomic, strong) NSMutableArray *pinnedComponentUnitLabels;

@end

@implementation TTExpirationPickerController

- (id)initWithExpirationTime:(NSTimeInterval)expirationTime {
    if (self = [super init]) {
        self.expirationTime = expirationTime;
        self.expirationUnits = [TTExpirationDomain expirationUnits];
        
        [self setBackgroundColor:kTTUIPurpleColor];
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
    [dismissButton setTitleColor:kTTUIPurpleColor forState:UIControlStateNormal];
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

#define kPickerWidthInset 8.0f
- (void)setupPickerView {
    [self.pickerView setFrame:CGRectMake(kPickerWidthInset, HEADER_HEIGHT, self.frame.size.width - 2 * kPickerWidthInset, PICKER_HEIGHT)];
    
    [self addSubview:self.pickerView];
    
    [self setupDefaultValues];
}

- (void)setupDefaultValues {
    [TTExpirationDomain setUnits:self.expirationUnits forExpirationTime:self.expirationTime];
    
    for (NSInteger i = 0; i < self.expirationUnits.count; i++) {
        TTExpirationUnit *unit = self.expirationUnits[i];
        [self.pickerView selectRow:(unit.currentValue - unit.minValue)
                       inComponent:i
                          animated:NO];
    }
    
    [self refreshPreviewLabel];
}

- (void)pinUnitLabelForComponent:(NSInteger)component {
    // Remove existing label from the view.
    [self.pinnedComponentUnitLabels[component] removeFromSuperview];
    
    TTExpirationPickerCell *selectedCell = (TTExpirationPickerCell *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:component] forComponent:component];
    
    UILabel *unitLabel = [[selectedCell copy] unitLabel];
    [unitLabel setHidden:NO];
    self.pinnedComponentUnitLabels[component] = unitLabel;
    
    [unitLabel setFrame:[selectedCell convertRect:unitLabel.frame toView:self]];
    [self addSubview:unitLabel];
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
    } completion:^(BOOL finished) {
        if (finished) {
            self.pinnedComponentUnitLabels = [NSMutableArray arrayWithCapacity:self.expirationUnits.count];
            for (int component = 0; component < self.expirationUnits.count; component++) {
                [self.pinnedComponentUnitLabels addObject:[[UIView alloc] init]];
                [self pinUnitLabelForComponent:component];
            }
        }
    }];
}

- (void)dismiss {
    [self.delegate pickerController:self didFinishWithExpiration:self.expirationTime];
    
    UIWindow *frontWindow = [self frontWindow];
    
    [UIView animateWithDuration:DISMISS_DURATION animations:^{
        [self.backgroundView setAlpha:0];
        [self setFrame:CGRectMake(0, frontWindow.frame.size.height, VIEW_WIDTH, VIEW_HEIGHT)];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Helper Methods
- (UIWindow *)frontWindow {
    return [[[UIApplication sharedApplication] windows] lastObject];
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.pickerView) {
        return self.expirationUnits.count;
    } else {
        return -1;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pickerView) {
        TTExpirationUnit *unit = self.expirationUnits[component];
        return unit.maxValue - unit.minValue + 1;
    } else {
        return -1;
    }
}

#pragma makr - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50.0f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pickerView) {
        TTExpirationUnit *unit = self.expirationUnits[component];
        unit.currentValue = unit.minValue + row;
        self.expirationTime = [TTExpirationDomain expirationTimeFromUnits:self.expirationUnits];
        
        [self pinUnitLabelForComponent:component];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    TTExpirationPickerCell *cell;
    if (pickerView == self.pickerView) {
        CGRect viewFrame = CGRectMake(0, 0, pickerView.frame.size.width / self.expirationUnits.count, 50.0f);
        
        // Reuse an existing view, if possible.
        if (view && [view isKindOfClass:[TTExpirationPickerCell class]]) {
            cell = (TTExpirationPickerCell *)view;
            [cell setFrame:viewFrame];
        } else {
            cell = [[TTExpirationPickerCell alloc] initWithFrame:viewFrame];
        }
        
        // Customize the view for this row and component.
        TTExpirationUnit *unit = self.expirationUnits[component];
        
        cell.textLabel.text = [unit stringValueForIndex:row];
        
        if (unit.minValue + row == 1) {
            cell.unitLabel.text = unit.singularTitle;
        } else {
            cell.unitLabel.text = unit.pluralTitle;
        }
    }
    
    return cell;
}

@end
