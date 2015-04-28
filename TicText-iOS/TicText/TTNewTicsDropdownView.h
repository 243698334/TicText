//
//  TTUnreadMessagesView.h
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTNewTicsDropdownSummaryView.h"
#import "TTNewTicsDropdownTableViewCell.h"

@class TTNewTicsDropdownView;

@protocol TTUnreadTicsListViewDelegate <NSObject>

- (void)receivedNewTicsDropdownViewDidSelectNewTicAtIndex:(NSInteger)index;

@end

@protocol TTUnreadTicsListViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInNewTicsDropdownView;

@required
- (NSInteger)numberOfUnreadTicsInNewTicsDropdownView;

@required
- (NSInteger)numberOfExpiredTicsInNewTicsDropdownView;

@required
- (TTNewTicsDropdownTableViewCell *)unreadTicsListView:(TTNewTicsDropdownView *)unreadTicsListView cellForRowAtIndex:(NSInteger)index;

@end

@interface TTNewTicsDropdownView : UIView <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TTNewTicsDropdownSummaryViewDataSource>

@property (nonatomic, assign) id<TTUnreadTicsListViewDelegate> delegate;
@property (nonatomic, assign) id<TTUnreadTicsListViewDataSource> dataSource;

+ (CGFloat)height;

- (void)reloadData;

@end
