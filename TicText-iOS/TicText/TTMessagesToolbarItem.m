//
//  TTMessagesToolbarItem.m
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesToolbarItem.h"

#import "TTMessagesToolbar.h"

@implementation TTMessagesToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:kTTUIPurpleColor forState:UIControlStateHighlighted];
        [self setTitleColor:kTTUIPurpleColor forState:UIControlStateSelected];
    }
    return self;
}

- (CGFloat)widthMultiplier {
    return 1.0f;
}

- (UIView *)contentView {
    static dispatch_once_t onceToken;
    static UIView *view = nil;
    dispatch_once(&onceToken, ^{
        view = [[UIView alloc] init];
        [view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    });
    return view;
}

- (void)didSelectToolbarButton:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    self.selected = YES;
}

- (void)didDeselectToolbarButton:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    self.selected = NO;
}

- (BOOL)shouldSwitchViewOnAction {
    return YES;
}

- (NSString *)className {
    return NSStringFromClass(self.class);
}

@end
