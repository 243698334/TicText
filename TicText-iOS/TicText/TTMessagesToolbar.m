//
//  TTMessagesToolbar.m
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesToolbar.h"

#import "TTMessagesToolbarItem.h"

@interface TTMessagesToolbar ()

@property (nonatomic, strong) NSArray *toolbarItems;

@end

@implementation TTMessagesToolbar

- (id)initWithFrame:(CGRect)frame toolbarItems:(NSArray *)items {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.toolbarItems = items;
        self.selectedIndex = -1;
        
        [self setupTopBorder];
        [self setupButtons];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return (self = [self initWithFrame:frame toolbarItems:@[]]);
}

- (CGRect)topBorderFrame {
    return CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
}

- (void)setupTopBorder {
    self.topBorder = [[UIView alloc] initWithFrame:[self topBorderFrame]];
    [self.topBorder setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    [self.topBorder setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self addSubview:self.topBorder];
}

- (void)setupButtons {
    for (int i = 0; i < self.toolbarItems.count; i++) {
        TTMessagesToolbarItem *item = self.toolbarItems[i];
        
        // Modify the button for our use.
        [item setFrame:[self frameForButtonIndex:i]];
        [item addTarget:self action:@selector(toggleItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:item];
    }
}

- (void)selectItemAtIndex:(NSInteger)index {
    TTMessagesToolbarItem *item = self.toolbarItems[index];
    [item sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)toggleItem:(TTMessagesToolbarItem *)item {
    for (TTMessagesToolbarItem *otherItem in self.toolbarItems) {
        if (item != otherItem) {
            if (otherItem.selected) {
                otherItem.selected = NO;
                [self.delegate messagesToolbar:self willHideItem:otherItem];
            }
        }
    }
    
    self.selectedIndex = [self.toolbarItems indexOfObject:item];
    NSLog(@"selected index is now %ld", self.selectedIndex);
    item.selected = YES;
    [self.delegate messagesToolbar:self willShowItem:item];
    
    // Add content view to window. Hopefully, the delegate displayed the keyboard so its UI
    // will automatically adjust.
}

#define kToolbarButtonWidth (self.frame.size.height)
#define kToolbarButtonHeight kToolbarButtonWidth
- (CGRect)frameForButtonIndex:(NSInteger)index {
    return CGRectMake(index * kToolbarButtonWidth, 0, kToolbarButtonWidth, kToolbarButtonHeight);
}

@end
