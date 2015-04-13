//
//  TTMessagesToolbarItem.m
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesToolbarItem.h"

@implementation TTMessagesToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitle:@"Aa" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:kTTUIPurpleColor forState:UIControlStateHighlighted];
        [self setTitleColor:kTTUIPurpleColor forState:UIControlStateSelected];
    }
    return self;
}

- (UIView *)contentView {
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}

@end
