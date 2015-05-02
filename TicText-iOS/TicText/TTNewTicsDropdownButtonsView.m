//
//  TTNewTicsDropdownButtonsView.m
//  TicText
//
//  Created by Kevin Yufei Chen on 5/1/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTNewTicsDropdownButtonsView.h"

#import <PureLayout/PureLayout.h>

@interface TTNewTicsDropdownButtonsView ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *clearAllExpiredTicsButton;
@property (nonatomic, strong) UIImageView *seperatorImageView;

@end

@implementation TTNewTicsDropdownButtonsView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width * (1 + 0.4), 3, self.bounds.size.width * 0.4, self.bounds.size.height - 3)];
        self.backButton.titleLabel.textColor = [UIColor whiteColor];
        self.backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.backButton.titleLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:16];
        [self.backButton setTitle:@"back" forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        
        self.clearAllExpiredTicsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width * 0.2, 3, self.bounds.size.width * 0.6, self.bounds.size.height - 3)];
        self.clearAllExpiredTicsButton.titleLabel.textColor = [UIColor whiteColor];
        self.clearAllExpiredTicsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.clearAllExpiredTicsButton.titleLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:16];
        [self.clearAllExpiredTicsButton setTitle:@"clear all expired Tics" forState:UIControlStateNormal];
        [self.clearAllExpiredTicsButton addTarget:self action:@selector(didTapClearAllExpiredTicsButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clearAllExpiredTicsButton];
        
        self.seperatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"NewTicsDropdownButtonsViewSeperator-%@w", @([UIScreen mainScreen].bounds.size.width)]]];
        self.seperatorImageView.frame = CGRectMake(0, 0, self.bounds.size.width, 3);
        [self addSubview:self.seperatorImageView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateFrames {
    if (self.isShowingTicsFromSameSender) {
        CGRect backButtonFrame = self.backButton.frame;
        backButtonFrame.origin.x = self.bounds.size.width * 0.6;
        self.backButton.frame = backButtonFrame;
        
        CGRect clearAllExpiredTicsButtonFrame = self.clearAllExpiredTicsButton.frame;
        clearAllExpiredTicsButtonFrame.origin.x = 0;
        self.clearAllExpiredTicsButton.frame = clearAllExpiredTicsButtonFrame;
    } else {
        CGRect backButtonFrame = self.backButton.frame;
        backButtonFrame.origin.x = self.bounds.size.width * (1 + 0.4);
        self.backButton.frame = backButtonFrame;
        
        CGRect clearAllExpiredTicsButtonFrame = self.clearAllExpiredTicsButton.frame;
        clearAllExpiredTicsButtonFrame.origin.x = self.bounds.size.width * 0.2;
        self.clearAllExpiredTicsButton.frame = clearAllExpiredTicsButtonFrame;
    }
}

- (void)didTapBackButton {
    if (self.delegate) {
        [self.delegate newTicsDropdownButtonsViewDidTapBackButton];
    }
}

- (void)didTapClearAllExpiredTicsButton {
    if (self.delegate) {
        [self.delegate newTicsDropdownButtonsViewDidTapClearAllExpiredTicsButton];
    }
}

@end
