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
    }
    return self;
}

- (void)setDelegate:(id<TTMessagesToolbarDelegate>)delegate {
    _delegate = delegate;
    
    [self setupButtons];
}

- (id)initWithFrame:(CGRect)frame {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InstalledToolbarItems" ofType:@"plist"];
    NSArray *itemClasses = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *itemClass in itemClasses) {
        [items addObject:[[NSClassFromString(itemClass) alloc] init]];
    }
    return (self = [self initWithFrame:frame toolbarItems:[NSArray arrayWithArray:items]]);
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
        item.toolbar = self;
        
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
    if ([self.toolbarItems indexOfObject:item] == self.selectedIndex) {
        return;
    }
    
    TTMessagesToolbarItem *oldItem = nil;
    if (self.selectedIndex >= 0) {
        oldItem = self.toolbarItems[self.selectedIndex];
        [oldItem buttonOnDeselect:self];
    }
    
    [item buttonOnSelect:self];
    if ([item switchViewOnAction]) {
        self.selectedIndex = [self.toolbarItems indexOfObject:item];
        [self.delegate messagesToolbar:self willShowItem:item];
    }
}

#define kToolbarButtonWidth (self.frame.size.height)
#define kToolbarButtonHeight kToolbarButtonWidth
- (CGRect)frameForButtonIndex:(NSInteger)index {
    CGFloat xOffset = 0.0f;
    for (int i = 0; i < index; i++) {
        xOffset += [self.toolbarItems[i] widthMultiplier] * kToolbarButtonWidth;
    }
    return CGRectMake(xOffset, 0, [self.toolbarItems[index] widthMultiplier] * kToolbarButtonWidth, kToolbarButtonHeight);
}

@end
