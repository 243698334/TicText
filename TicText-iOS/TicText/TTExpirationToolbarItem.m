//
//  TTExpirationToolbarItem.m
//  TicText
//
//  Created by Terrence K on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationToolbarItem.h"
#import "TTMessagesToolbar.h"

#import "TTExpirationDomain.h"

@implementation TTExpirationToolbarItem

@synthesize toolbar = _toolbar;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitle:@"Expires in\n---" forState:UIControlStateNormal];
        [self.titleLabel setNumberOfLines:2];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    return self;
}

- (UIView *)contentView {
    return nil;
}

- (CGFloat)widthMultiplier {
    return 3.0f;
}

- (void)didSelectToolbarButton:(TTMessagesToolbar *)toolbar {
    if (toolbar != self.toolbar) {
        return;
    }
    
    [self.pickerController dismiss];
    
    self.pickerController = [[TTExpirationPickerController alloc] initWithExpirationTime:[toolbar.delegate expirationTime]];
    [self.pickerController setDelegate:self];
    [self.pickerController present];
}

- (void)didDeselectToolbarButton:(TTMessagesToolbar *)toolbar {
    return;
}

- (BOOL)shouldSwitchViewOnAction {
    return NO;
}

- (void)setToolbar:(TTMessagesToolbar *)toolbar {
    _toolbar = toolbar;
    
    [self refreshTitle];
}

#pragma mark - TTExpirationPickerControllerDelegate
- (void)pickerController:(TTExpirationPickerController *)controller didFinishWithExpiration:(NSTimeInterval)expirationTime {
    if (controller != self.pickerController) {
        return;
    }
    
    [self.toolbar.delegate messagesToolbar:self.toolbar setExpirationTime:expirationTime];
    
    [self refreshTitle];
}

#pragma mark - Helpers
- (void)refreshTitle {
    NSTimeInterval expirationTime = [self.toolbar.delegate expirationTime];
    [self setTitle:[TTExpirationDomain shortStringForTimeInterval:expirationTime] forState:UIControlStateNormal];
}

@end
