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
- (void)pickerControllerDidFinishPicking:(TTExpirationPickerController *)controller;
@end

@interface TTExpirationPickerController : UIView

@property (nonatomic, weak) id<TTExpirationPickerControllerDelegate> delegate;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *previewLabel;

- (id)initWithPickerView:(UIPickerView *)pickerView;
- (void)present;
- (void)dismiss;

@end
