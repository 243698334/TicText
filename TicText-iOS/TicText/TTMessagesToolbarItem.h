//
//  TTMessagesToolbarItem.h
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTMessagesToolbar;
@interface TTMessagesToolbarItem : UIButton

// Reference to the toolbar that is showing this toolbar item.
// Automatically set by the toolbar when it's initialized containing an instance of this item.
@property (nonatomic, weak) TTMessagesToolbar *toolbar;

// Helper to get the class name for unit testing.
@property (nonatomic, readonly) NSString *className;

// Displayed by the toolbar's owner when this item is selected.
@property (nonatomic, readonly) UIView *contentView;

// Used to give this item more or less width when presented in the toolbar.
- (CGFloat)widthMultiplier;

// Called by the toolbar when this button is selected.
// @Note This is not called multiple times if this item is currently selected.
- (void)didSelectToolbarButton:(TTMessagesToolbar *)toolbar;

// Called by the toolbar when this button is deselected.
// @Note This will not be called if the newly selected item's |switchViewOnAction| returns NO.
- (void)didDeselectToolbarButton:(TTMessagesToolbar *)toolbar;

// Used by the toolbar and its owner to determine interactions with this item.
- (BOOL)shouldSwitchViewOnAction;

@end
