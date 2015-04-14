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
        [self setTitle:@"NN" forState:UIControlStateNormal];
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
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    return view;
}

- (void)buttonOnSelect:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    self.selected = YES;
}

- (void)buttonOnDeselect:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    self.selected = NO;
}

- (BOOL)switchViewOnAction {
    return YES;
}

@end
