//
//  ScrollToTopView.m
//  AdjustingSectionHeader
//
//  Created by Jack Arendt on 3/14/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTNewTicsBannerView.h"
#define kShrunkHeight 44
#import "TTConstants.h"

@interface TTNewTicsBannerView () {
    BOOL _visible;
}

@property (nonatomic, assign) BOOL isUnreadTicsListVisible;
@property (nonatomic, strong) UIButton *bannerButton;

@end

CGFloat kTTNewTicsBannerViewHeight = 44;

@implementation TTNewTicsBannerView

+ (CGFloat)height {
    return kTTNewTicsBannerViewHeight;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isUnreadTicsListVisible = NO;
        
        CGFloat radius = kShrunkHeight - 20;
        self.backgroundColor = kTTUIPurpleColor;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.bounds.size.width - 120, self.bounds.size.height)];
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.numberOfNewTicsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50, 10, 30, radius)];
        self.numberOfNewTicsLabel.textColor = kTTUIPurpleColor;
        self.numberOfNewTicsLabel.backgroundColor = [UIColor whiteColor];
        self.numberOfNewTicsLabel.textAlignment = NSTextAlignmentCenter;
        CALayer *unreadTicsCountLabelLayer = self.numberOfNewTicsLabel.layer;
        [unreadTicsCountLabelLayer setMasksToBounds:YES];
        [unreadTicsCountLabelLayer setCornerRadius:12];
        [self addSubview:self.numberOfNewTicsLabel];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10 + (frame.size.height - kShrunkHeight)/2, radius, radius)];
        iv.image = [UIImage imageNamed:@"TicTextIconLightSmall"];
        [self addSubview:iv];
        
        self.bannerButton = [[UIButton alloc] initWithFrame:self.bounds];
        [self.bannerButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bannerButton];
        
    }
    return self;
}

- (void)reloadData {
    if (self.dataSource) {
        NSInteger numberOfUnreadTics = [self.dataSource numberOfNewTicsInNewTicsBannerView];
        self.numberOfNewTicsLabel.text = [NSString stringWithFormat:@"%li", numberOfUnreadTics];
        self.titleLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:self.titleLabel.font.pointSize];
    }
    [self updateTitleWithNewTicsDropdownVisibile:self.isUnreadTicsListVisible];
}

- (void)updateTitleWithNewTicsDropdownVisibile:(BOOL)visible {
    self.isUnreadTicsListVisible = visible;
    
    if (self.dataSource && [self.dataSource numberOfNewTicsInNewTicsBannerView] == 0) {
        self.titleLabel.text = @"You have no new Tics";
        return;
    }
    
    if (self.isUnreadTicsListVisible) {
        self.titleLabel.text = @"Tap to dismiss";
    } else {
        self.titleLabel.text = @"Tap to view your unread Tics";
    }
}

- (void)buttonPressed {
    if (self.delegate) {
        [self.delegate didTapNewTicsBanner];
    }
}

@end
