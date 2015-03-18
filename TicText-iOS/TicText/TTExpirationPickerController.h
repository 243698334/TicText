//
//  TTPickerContainer.h
//  TicText
//
//  Created by Terrence K on 3/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTExpirationPickerController;
@protocol TTExpirationPickerControllerDelegate <NSObject>

// Method to let the picker controller notify a delegate when an expiration time was selected by the user.
- (void)pickerController:(TTExpirationPickerController *)controller didFinishWithExpiration:(NSTimeInterval)expirationTime;

@end

@interface TTExpirationPickerController : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<TTExpirationPickerControllerDelegate> delegate;

@property (nonatomic) NSTimeInterval expirationTime;
@property (nonatomic, strong) NSArray *expirationUnits;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UILabel *previewLabel;

// Initializes the instance with a given |expirationTime|.
- (id)initWithExpirationTime:(NSTimeInterval)expirationTime;

// Presents the controller.
- (void)present;

// Dismisses the controller.
- (void)dismiss;

// Returns the window that this controller will attach to when presented.
- (UIWindow *)frontWindow;

@end
