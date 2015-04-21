//
//  TTMessagesToolbar.h
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTMessagesToolbar, TTMessagesToolbarItem;
@protocol TTMessagesToolbarDelegate <NSObject>

// Called by the toolbar when a newly selected item has a |contentView| to show.
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar willShowItem:(TTMessagesToolbarItem *)item;

// Called by the toolbar when the currently selected item's |contentView| will be hidden.
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar willHideItem:(TTMessagesToolbarItem *)item;

// Called by the toolbar when it wants to set the anonymity of the draft Tic.
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar setAnonymousTic:(BOOL)anonymous;

// Called by the toolbar when it wants to set the |expirationTime| of the draft Tic.
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar setExpirationTime:(NSTimeInterval)expirationTime;

// Called by toolbar items that want to obtain the current |expirationTime| of the draft Tic.
- (NSTimeInterval)expirationTime;

@end

@interface TTMessagesToolbar : UIView

// This toolbar's owner that will be responsible for displaying and managing the
// currently selected item's |contentView|.
@property (nonatomic, weak) id<TTMessagesToolbarDelegate> delegate;

// The array used internally to hold the toolbar items.
@property (nonatomic, strong) NSArray *toolbarItems;

// A sliver view displayed along the top side of this toolbar that is exposed to this toolbar's
// owner so it can, when needed, hide or show.
@property (nonatomic, strong) UIView *topBorder;

// An index value in |toolbarItems| to indicate the currently selected item. Only one item can be
// selected at one time. The selected item is the one being displayed by this toolbar's owner, and
// does not include items that are "toggled on."
// @Note When no item is selected, |selectedIndex| is -1.
@property (atomic) NSInteger selectedIndex;

// Initializes the toolbar with an alternative array of toolbar items. The order of the items in
// this array, from left-to-right, will be the same order they will be presented in.
- (id)initWithFrame:(CGRect)frame toolbarItems:(NSArray *)items;

// Programatically selects an item at the specified index.
- (void)selectItemAtIndex:(NSInteger)index;

@end

@interface TTMessagesToolbar (PrivateMethods)

// Frame, respective to the toolbar, for the |topBorder| view.
- (CGRect)topBorderFrame;

// Helper method to initially size and place the |topBorder| view.
- (void)setupTopBorder;

// Helper method to initially size and place the |toolbarItems| in the toolbar view.
// @Note Also adds the button action hook to |toggleItem:| onto the |toolbarItems|.
- (void)setupButtons;

// Action method added to the |toolbarItems| that is the core of toolbar functionality.
- (void)toggleItem:(TTMessagesToolbarItem *)item;

// Calculates and returns the frame for a |toolbarItem| with the given index.
- (CGRect)frameForButtonIndex:(NSInteger)index;

@end
