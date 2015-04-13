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

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.toolbarItems = @[
          [[TTMessagesToolbarItem alloc] init],
          [[TTMessagesToolbarItem alloc] init],
          [[TTMessagesToolbarItem alloc] init]
        ];
        
        [self setupButtons];
    }
    return self;
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

- (void)toggleItem:(TTMessagesToolbarItem *)item {
    NSLog(@"button pressed.");
    for (TTMessagesToolbarItem *otherItem in self.toolbarItems) {
        if (item != otherItem) {
            if (otherItem.selected) {
                otherItem.selected = NO;
                [self.delegate messagesToolbar:self willHideItem:otherItem];
            }
        }
    }
    
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
