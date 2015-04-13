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
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    }
    return self;
}

- (UIView *)contentView {
    return [[UIView alloc] init];
}

@end
