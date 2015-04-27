//
//  TTUnreadMessagesView.h
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTUnreadTicsListTableViewCell.h"

@class TTUnreadTicsListView;

@protocol TTUnreadTicsListViewDelegate <NSObject>

- (void)unreadTicsListViewDidSelectUnreadTicAtIndex:(NSInteger)index;

@end

@protocol TTUnreadTicsListViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInUnreadTicsList;

@required
- (TTUnreadTicsListTableViewCell *)unreadTicsListView:(TTUnreadTicsListView *)unreadTicsListView cellForRowAtIndex:(NSInteger)index;

@end

@interface TTUnreadTicsListView : UIView <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id<TTUnreadTicsListViewDelegate> delegate;
@property (nonatomic, assign) id<TTUnreadTicsListViewDataSource> dataSource;

- (CGFloat)requiredHeight;

- (void)reloadData;

@end
