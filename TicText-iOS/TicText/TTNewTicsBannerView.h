//
//  ScrollToTopView.h
//  AdjustingSectionHeader
//
//  Created by Jack Arendt on 3/14/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTNewTicsBannerViewDelegate <NSObject>

- (void)didTapNewTicsBanner;

@end

@protocol TTNewTicsBannerViewDataSource <NSObject>

@required
- (NSInteger)numberOfNewTicsInNewTicsBannerView;

@end


@interface TTNewTicsBannerView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *numberOfNewTicsLabel;

@property (nonatomic, assign) id<TTNewTicsBannerViewDelegate> delegate;
@property (nonatomic, assign) id<TTNewTicsBannerViewDataSource> dataSource;

+ (CGFloat)height;

- (void)reloadData;

- (void)updateTitleWithNewTicsDropdownVisibile:(BOOL)visible;

@end
