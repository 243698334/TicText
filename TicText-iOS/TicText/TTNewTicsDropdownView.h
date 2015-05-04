//
//  TTUnreadMessagesView.h
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTNewTicsDropdownSummaryView.h"
#import "TTNewTicsDropdownButtonsView.h"
#import "TTNewTicsDropdownTableViewCell.h"

@class TTNewTicsDropdownView;

@protocol TTNewTicsDropdownViewDelegate <NSObject>

- (BOOL)tableView:(UITableView *)tableView shouldShowTicsFromSameSenderWhenNewTicsDropdownViewDidSelectRowAtIndex:(NSInteger)index;

- (void)newTicsDropdownViewDidTapBackButton;

- (void)newTicsDropdownViewDidTapClearAllExpiredTicsButton;

@end

@protocol TTNewTicsDropdownViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInNewTicsDropdownViewTableView:(UITableView *)tableView;

@required
- (NSInteger)numberOfUnreadTicsInNewTicsDropdownView;

@required
- (NSInteger)numberOfExpiredTicsInNewTicsDropdownView;

@required
- (TTNewTicsDropdownTableViewCell *)tableView:(UITableView *)tableView cellForRowInNewTicsDropdownViewAtIndex:(NSInteger)index;

@end

extern NSInteger const kTTNewTicsDropdownViewAllNewTicsTableViewTag;
extern NSInteger const kTTNewTicsDropdownViewSameSenderNewTicsTableViewTag;

@interface TTNewTicsDropdownView : UIView <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TTNewTicsDropdownSummaryViewDataSource, TTNewTicsDropdownButtonsViewDelegate>

@property (nonatomic, assign) id<TTNewTicsDropdownViewDelegate> delegate;
@property (nonatomic, assign) id<TTNewTicsDropdownViewDataSource> dataSource;

+ (CGFloat)initialHeight;

+ (CGFloat)fullViewHeight;

- (void)reloadData;

@end
