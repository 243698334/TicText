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

- (void)messagesToolbar:(TTMessagesToolbar *)toolbar willShowItem:(TTMessagesToolbarItem *)item;
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar willHideItem:(TTMessagesToolbarItem *)item;
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar setAnonymousTic:(BOOL)anonymous;
- (void)messagesToolbar:(TTMessagesToolbar *)toolbar setExpirationTime:(NSTimeInterval)expirationTime;
- (NSTimeInterval)currentExpirationTime;

@end

@interface TTMessagesToolbar : UIView

@property (nonatomic, weak) id<TTMessagesToolbarDelegate> delegate;
@property (nonatomic, strong) UIView *topBorder;
@property (atomic) NSInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame toolbarItems:(NSArray *)items;
- (void)selectItemAtIndex:(NSInteger)index;

@end
