//
//  TTScrollingImagePickerCell.m
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTScrollingImagePickerCell.h"

#import <PureLayout/PureLayout.h>

@interface TTScrollingImagePickerCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *optionButtonsView;

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
    
    UIButton *sendButton = [[UIButton alloc] init];
    NSLog(@"Frame Height: %f", self.imageView.frame.size.height);
    sendButton.frame = self.contentView.bounds;
    sendButton.titleLabel.text = @"Send";
    sendButton.titleLabel.textColor = [UIColor whiteColor];
    sendButton.backgroundColor = [UIColor colorWithRed:130.0/255.0 green:100.0/255.0 blue:200.0/255.0 alpha:0.8];
    CALayer *imagePickerButtonLayer = sendButton.layer;
    [imagePickerButtonLayer setMasksToBounds:YES];
    [imagePickerButtonLayer setCornerRadius:25];
    [sendButton addTarget:self action:@selector(didTapSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionButtonsView addSubview:sendButton];
    [self.optionButtonsView bringSubviewToFront:sendButton];
    //[self.optionButtonsView autoSetDimensionsToSize:CGSizeMake(70, 70)];
    [self.contentView addSubview:self.optionButtonsView];
    [self.contentView bringSubviewToFront:self.optionButtonsView];

//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.25;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionReveal;
//    transition.delegate = self;
//    [self.contentView addSubview:self.optionButtonsView];
//    [self.contentView.layer addAnimation:transition forKey:nil];
    
    //[self.contentView setNeedsLayout];
}

- (void)hideOptionButtons {
    [self.optionButtonsView removeFromSuperview];
}

- (void)didTapSendButton:(id)sender {
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setSelected:NO];
}

@end
