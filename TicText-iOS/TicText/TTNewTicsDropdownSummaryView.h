//
//  TTUnreadTicsListSummaryView.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTNewTicsDropdownSummaryViewDataSource <NSObject>

@required
- (NSInteger)numberOfExpiredTics;

@required
- (NSInteger)numberOfUnreadTics;

@end

@interface TTNewTicsDropdownSummaryView : UIView

@property (nonatomic, assign) BOOL isShowingLandscapeLayout;
@property (nonatomic, assign) id<TTNewTicsDropdownSummaryViewDataSource> dataSource;

- (void)reloadData;

- (void)updateFrames;

@end
