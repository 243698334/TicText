//
//  TTScrollingImagePickerCell.m
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTScrollingImagePickerCell.h"

#import <PureLayout/PureLayout.h>

#define kSendButtonRadius 40

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
    [self setNeedsUpdateConstraints];
    
    self.optionButtonsView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.optionButtonsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    [self.bluredEffectView setFrame:self.optionButtonsView.bounds];
    [self.optionButtonsView addSubview:self.bluredEffectView];
    
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.sendButton.center = self.superview.center;
//    CGRect tempFrame = self.sendButton.frame;
//    tempFrame.size.height = kSendButtonRadius;
//    tempFrame.size.width = kSendButtonRadius;
//    self.sendButton.frame = tempFrame;
    self.sendButton.frame = CGRectMake(0, 0, kSendButtonRadius, kSendButtonRadius);
    self.sendButton.titleLabel.text = @"Send";
    self.sendButton.titleLabel.textColor = [UIColor whiteColor];
    self.sendButton.backgroundColor = [UIColor colorWithRed:130.0/255.0 green:100.0/255.0 blue:200.0/255.0 alpha:0.8];
    
    [self.sendButton.layer setMasksToBounds:YES];
    [self.sendButton.layer setCornerRadius:kSendButtonRadius/2.0f];
    [self.sendButton addTarget:self action:@selector(didTapSendButton) forControlEvents:UIControlEventTouchUpInside];
    [self.optionButtonsView addSubview:self.sendButton];
    [self.optionButtonsView bringSubviewToFront:self.sendButton];
    
    self.optionButtonsView.alpha = 0.0;
    [self.contentView addSubview:self.optionButtonsView];
    [UIView animateWithDuration:0.25 animations:^{
        self.optionButtonsView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.contentView bringSubviewToFront:self.optionButtonsView];
    }];
}

- (void)didTapSendButton {
    if (self.delegate) {
        [self.delegate didTapSendButtonInScrollingImagePickerCell];
    }
}

- (void)hideOptionButtons {
    [self.bluredEffectView removeFromSuperview];
    [self.optionButtonsView removeFromSuperview];
}

- (void)updateConstraints {
    [self.sendButton autoCenterInSuperview];
    [super updateConstraints];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setSelected:NO];
    [self.bluredEffectView removeFromSuperview];
    [self.optionButtonsView removeFromSuperview];
}

@end
