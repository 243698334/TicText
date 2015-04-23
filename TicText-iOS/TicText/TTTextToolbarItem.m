//
//  TTTextToolbarItem.m
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTTextToolbarItem.h"

@implementation TTTextToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitle:@"Aa" forState:UIControlStateNormal];
    }
    return self;
}

- (UIView *)contentView {
    return nil;
}

@end
