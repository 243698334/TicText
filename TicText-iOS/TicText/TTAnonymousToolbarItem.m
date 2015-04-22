//
//  TTAnonymousToolbarItem.m
//  TicText
//
//  Created by Terrence K on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTAnonymousToolbarItem.h"
#import "TTMessagesToolbar.h"

@implementation TTAnonymousToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitle:@"Anonymous" forState:UIControlStateNormal];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        
        self.selected = NO;
    }
    return self;
}

- (UIView *)contentView {
    return nil;
}

- (CGFloat)widthMultiplier {
    return 2.0f;
}

- (void)didSelectToolbarButton:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    if ((self.selected = !self.selected)) {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
    } else {
        [self.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    }
    
    [self.toolbar.delegate messagesToolbar:toolbar setAnonymousTic:self.selected];
}

- (void)didDeselectToolbarButton:(TTMessagesToolbar *)toolbar {
    return;
}

- (BOOL)shouldSwitchViewOnAction {
    return NO;
}

@end
