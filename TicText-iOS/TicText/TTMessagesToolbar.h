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

@end

@interface TTMessagesToolbar : UIView

@property (nonatomic, weak) id<TTMessagesToolbarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame toolbarItems:(NSArray *)items;
- (void)selectItemAtIndex:(NSInteger)index;

@end
