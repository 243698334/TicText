//
//  TTScrollingImagePickerCell.m
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTScrollingImagePickerCell.h"

#import <PureLayout/PureLayout.h>

#define kSendButtonRadius 60.0
#define kSendButtonBorderWidth 2.0

@interface TTScrollingImagePickerCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *optionButtonsView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIVisualEffectView *bluredEffectView;

@end

@implementation TTScrollingImagePickerCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)showOptionButtons {
    self.optionButtonsView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.optionButtonsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    [self.bluredEffectView setFrame:self.optionButtonsView.bounds];
    [self.optionButtonsView addSubview:self.bluredEffectView];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kSendButtonRadius, kSendButtonRadius)];
    [self.sendButton.layer setCornerRadius:kSendButtonRadius/2.0f];
    [self.sendButton.layer setBorderWidth:kSendButtonBorderWidth];
    [self.sendButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.sendButton.layer setMasksToBounds:YES];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];;
    [self.sendButton setTitleColor:kTTUIPurpleColor forState:UIControlStateHighlighted];
    [self.sendButton setBackgroundColor:kTTUIPurpleColor];
    [self.sendButton setAlpha:0.7];

    [self.sendButton addTarget:self action:@selector(toggleButtonColor:) forControlEvents:UIControlEventTouchDown];
    [self.sendButton addTarget:self action:@selector(toggleButtonColor:) forControlEvents:UIControlEventTouchUpOutside];
    [self.sendButton addTarget:self action:@selector(didTapSendButton) forControlEvents:UIControlEventTouchUpInside];
    [self.optionButtonsView addSubview:self.sendButton];
    [self.optionButtonsView bringSubviewToFront:self.sendButton];
    
    // Put send button at center
    self.sendButton.center = self.optionButtonsView.center;
    CGRect tempFrame = self.sendButton.frame;
    tempFrame.size.height = kSendButtonRadius;
    tempFrame.size.width = kSendButtonRadius;
    self.sendButton.frame = tempFrame;
    
    [self.optionButtonsView setAlpha:0.0];
    [self.contentView addSubview:self.optionButtonsView];
    [UIView animateWithDuration:0.25 animations:^{
        [self.optionButtonsView setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self.contentView bringSubviewToFront:self.optionButtonsView];
    }];
}

- (void)toggleButtonColor:(id)sender {
    UIButton *sendButton = (UIButton *)sender;
    if (sendButton.isHighlighted) {
        [UIView animateWithDuration:0.25 animations:^{
            sendButton.backgroundColor = [UIColor whiteColor];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            sendButton.backgroundColor = kTTUIPurpleColor;
        }];
    }
}

- (void)didTapSendButton {
    if (self.delegate) {
        [self.delegate didTapSendButtonInScrollingImagePickerCell:self];
    }
}

- (void)hideOptionButtons {
    [self.contentView addSubview:self.optionButtonsView];
    [UIView animateWithDuration:0.25 animations:^{
        [self.optionButtonsView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.optionButtonsView removeFromSuperview];
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setSelected:NO];
    [self.optionButtonsView removeFromSuperview];
}

@end
