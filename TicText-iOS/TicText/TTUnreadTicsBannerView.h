//
//  ScrollToTopView.h
//  AdjustingSectionHeader
//
//  Created by Jack Arendt on 3/14/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTUnreadTicsBannerViewDelegate <NSObject>

- (void)didTapUnreadTicsBanner;

@end

@protocol TTUnreadTicsBannerViewDataSource <NSObject>

@required
- (NSInteger)numberOfUnreadTicsInUnreadTicsBannerView;

@end


@interface TTUnreadTicsBannerView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *unreadTicsCountLabel;

@property (nonatomic, assign) id<TTUnreadTicsBannerViewDelegate> delegate;
@property (nonatomic, assign) id<TTUnreadTicsBannerViewDataSource> dataSource;

- (void)reloadData;

- (void)updateTitleWithUnreadTicsListVisibile:(BOOL)visible;

@end
