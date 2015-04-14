//
//  TTAnonymousToolbarItem.m
//  TicText
//
//  Created by Terrence K on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTAnonymousToolbarItem.h"
#import "TTMessagesToolbar.h"

@interface TTAnonymousToolbarItem ()

@property (nonatomic) BOOL isAnonymous;

@end

@implementation TTAnonymousToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitle:@"Anonymous" forState:UIControlStateNormal];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        
        self.isAnonymous = NO;
    }
    return self;
}

- (UIView *)contentView {
    return nil;
}

- (CGFloat)widthMultiplier {
    return 2.0f;
}

- (void)buttonOnSelect:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    BOOL newValue = !self.isAnonymous;
    self.isAnonymous = self.selected = newValue;
    if (newValue) {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
    } else {
        [self.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    }
    
    [self.toolbar.delegate messagesToolbar:toolbar setAnonymousTic:self.isAnonymous];
}

- (void)buttonOnDeselect:(TTMessagesToolbar *)toolbar {
    return;
}

- (BOOL)switchViewOnAction {
    return NO;
}

@end
