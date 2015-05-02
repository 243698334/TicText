//
//  TTUnreadMessagesView.m
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTNewTicsDropdownView.h"

#import <PureLayout/PureLayout.h>
#import "TTNewTicsBannerView.h"

@interface TTNewTicsDropdownView ()

@property (nonatomic, assign) BOOL isShowingFullView;
@property (nonatomic, assign) BOOL isShowingTicsFromSameSender;
@property (nonatomic, assign) BOOL isScrollHintLabelVisible;

@property (nonatomic, strong) TTNewTicsDropdownSummaryView *summaryView;
@property (nonatomic, strong) TTNewTicsDropdownButtonsView *buttonsView;
@property (nonatomic, strong) UITableView *allNewTicsTableView;
@property (nonatomic, strong) UITableView *sameSenderNewTicsTableView;
@property (nonatomic, strong) UILabel *scrollHintLabel;
@property (nonatomic, strong) UIButton *showMoreButton;

@property (nonatomic, strong) NSTimer *updateCellTimer;

@property (nonatomic, strong) NSMutableArray *summaryViewConstraints;

@end

NSInteger const kTTNewTicsDropdownViewAllNewTicsTableViewTag = 0;
NSInteger const kTTNewTicsDropdownViewSameSenderNewTicsTableViewTag = 1;

NSInteger const kNewTicsDropdownViewMaximumNumberOfRowsShown = 5;
CGFloat const kNewTicsDropdownViewScrollHintLabelHeight = 20;
CGFloat const kNewTicsDropdownViewShowMoreButtonHeight = 20;

@implementation TTNewTicsDropdownView

+ (CGFloat)initialHeight {
    return kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height] + kNewTicsDropdownViewScrollHintLabelHeight + kNewTicsDropdownViewShowMoreButtonHeight;
}

+ (CGFloat)fullViewHeight {
    return [UIScreen mainScreen].bounds.size.height - 20 /*status bar*/ - 44 /*navigation bar*/ - 49 /*tab bar*/ - [TTNewTicsBannerView height];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // summary view
        self.summaryView = [[TTNewTicsDropdownSummaryView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width * 0.3, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height])];
        self.summaryView.dataSource = self;
        [self addSubview:self.summaryView];
        
        // buttons view
        self.buttonsView = [[TTNewTicsDropdownButtonsView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, [TTNewTicsDropdownTableViewCell height])];
        self.buttonsView.isShowingTicsFromSameSender = NO;
        self.buttonsView.delegate = self;
        self.buttonsView.hidden = YES;
        [self addSubview:self.buttonsView];
        
        // table view
        self.allNewTicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 0.3, 0, self.bounds.size.width * 0.7, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height]) style:UITableViewStylePlain];
        self.allNewTicsTableView.tag = kTTNewTicsDropdownViewAllNewTicsTableViewTag;
        self.allNewTicsTableView.delegate = self;
        self.allNewTicsTableView.dataSource = self;
        self.allNewTicsTableView.clipsToBounds = YES;
        self.allNewTicsTableView.backgroundColor = [UIColor clearColor];
        self.allNewTicsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.allNewTicsTableView registerClass:[TTNewTicsDropdownTableViewCell class] forCellReuseIdentifier:[TTNewTicsDropdownTableViewCell reuseIdentifier]];
        [self.allNewTicsTableView reloadData];
        [self addSubview:self.allNewTicsTableView];
        
        // same sender table view
        self.sameSenderNewTicsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.sameSenderNewTicsTableView.tag = kTTNewTicsDropdownViewSameSenderNewTicsTableViewTag;
        self.sameSenderNewTicsTableView.delegate = self;
        self.sameSenderNewTicsTableView.dataSource = self;
        self.sameSenderNewTicsTableView.clipsToBounds = YES;
        self.sameSenderNewTicsTableView.backgroundColor = [UIColor clearColor];
        self.sameSenderNewTicsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.sameSenderNewTicsTableView registerClass:[TTNewTicsDropdownTableViewCell class] forCellReuseIdentifier:[TTNewTicsDropdownTableViewCell reuseIdentifier]];
        [self addSubview:self.sameSenderNewTicsTableView];
        
        // scroll hint label
        self.scrollHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width * 0.3 + 15, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height], self.bounds.size.width * 0.7 - 15, kNewTicsDropdownViewScrollHintLabelHeight)];
        self.scrollHintLabel.text = @"scroll up to view more...";
        self.scrollHintLabel.textAlignment = NSTextAlignmentLeft;
        self.scrollHintLabel.textColor = [UIColor whiteColor];
        self.scrollHintLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:12];
        self.scrollHintLabel.alpha = 0.0;
        self.isScrollHintLabelVisible = NO;
        [self addSubview:self.scrollHintLabel];
        
        // show more button
        self.showMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height] + kNewTicsDropdownViewScrollHintLabelHeight, self.bounds.size.width, kNewTicsDropdownViewShowMoreButtonHeight)];
        self.showMoreButton.titleLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:26];
        [self.showMoreButton setTitle:@"⌄" forState:UIControlStateNormal];
        [self.showMoreButton addTarget:self action:@selector(didTapShowMoreButton) forControlEvents:UIControlEventTouchUpInside];
        //self.showMoreButton.imageView.image = [UIImage imageNamed:@"NewTicsDropdownViewShowMoreButtonIcon"];
        //self.showMoreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.showMoreButton];
        
        // background image
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"NewTicsDropdownViewBackground-%@w", @([UIScreen mainScreen].bounds.size.width)]]];
        
        self.isShowingFullView = NO;
        self.isShowingTicsFromSameSender = NO;
     }
    return self;
}

- (void)reloadData {
    if (self.dataSource) {
        if (self.isShowingTicsFromSameSender) {
            if ([self.dataSource numberOfRowsInNewTicsDropdownViewTableView:self.sameSenderNewTicsTableView] > kNewTicsDropdownViewMaximumNumberOfRowsShown) {
                self.isScrollHintLabelVisible = YES;
                self.scrollHintLabel.alpha = 1.0;
            }
        } else {
            if ([self.dataSource numberOfRowsInNewTicsDropdownViewTableView:self.allNewTicsTableView] > kNewTicsDropdownViewMaximumNumberOfRowsShown) {
                self.isScrollHintLabelVisible = YES;
                self.scrollHintLabel.alpha = 1.0;
            }
        }
        
        if (self.updateCellTimer == nil) {
            self.updateCellTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTableViewCells) userInfo:nil repeats:YES];
        }
        [self updateTableViewCells];
        [self.summaryView reloadData];
    }
}

- (void)updateTableViewCells {
    [self.allNewTicsTableView reloadData];
    if (self.isShowingTicsFromSameSender) {
        [self.sameSenderNewTicsTableView reloadData];
    }
}

- (void)showFullDropdownView {
    self.isShowingFullView = YES;
    self.summaryView.isShowingLandscapeLayout = YES;

    CGRect fullViewFrame = self.frame;
    fullViewFrame.size.height = [TTNewTicsDropdownView fullViewHeight];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = fullViewFrame;
        
        self.summaryView.frame = CGRectMake(0, 0, self.bounds.size.width, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height] / 2);
        [self.summaryView updateFrames];
        
        self.buttonsView.frame = CGRectMake(0, self.summaryView.frame.size.height + 10, self.bounds.size.width, [TTNewTicsDropdownTableViewCell height]);
        self.buttonsView.hidden = NO;
        [self.buttonsView updateFrames];
        
        self.allNewTicsTableView.frame = CGRectMake(0, self.buttonsView.frame.origin.y + self.buttonsView.frame.size.height + 10, self.bounds.size.width, self.bounds.size.height - kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height] / 2 - [TTNewTicsDropdownTableViewCell height] - 20 - kNewTicsDropdownViewShowMoreButtonHeight);
        
        self.sameSenderNewTicsTableView.frame = CGRectMake(self.bounds.size.width, self.buttonsView.frame.origin.y + self.buttonsView.frame.size.height + 10, self.bounds.size.width * 0.7, self.allNewTicsTableView.frame.size.height);
        
        self.scrollHintLabel.frame = CGRectMake(15, [TTNewTicsDropdownView fullViewHeight] - kNewTicsDropdownViewShowMoreButtonHeight - kNewTicsDropdownViewScrollHintLabelHeight, self.bounds.size.width - 15, kNewTicsDropdownViewScrollHintLabelHeight);
        
        self.showMoreButton.frame = CGRectMake(0, self.bounds.size.height - kNewTicsDropdownViewShowMoreButtonHeight, self.bounds.size.width, kNewTicsDropdownViewShowMoreButtonHeight);
        [self.showMoreButton setTitle:@"⌃" forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        if (self.isShowingTicsFromSameSender) {
            [self showSameSenderNewTicsTableView];
        }
        [self updateScrollHintLabelVisibility];
    }];
    
}

- (void)showHalfDropdownView {
    self.isShowingFullView = NO;
    self.summaryView.isShowingLandscapeLayout = NO;
    
    CGRect halfViewFrame = self.frame;
    halfViewFrame.size.height = [TTNewTicsDropdownView initialHeight];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = halfViewFrame;
        
        self.summaryView.frame = CGRectMake(0, 0, self.bounds.size.width * 0.3, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height]);
        [self.summaryView updateFrames];
        
        self.buttonsView.frame = CGRectZero;
        self.buttonsView.hidden = YES;
        
        self.allNewTicsTableView.frame = CGRectMake(self.bounds.size.width * 0.3, 0, self.bounds.size.width * 0.7, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height]);
        
        self.sameSenderNewTicsTableView.frame = CGRectZero;
        
        self.scrollHintLabel.frame = CGRectMake(self.bounds.size.width * 0.3 + 15, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height], self.bounds.size.width * 0.7 - 15, kNewTicsDropdownViewScrollHintLabelHeight);
        
        self.showMoreButton.frame = CGRectMake(0, kNewTicsDropdownViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height] + kNewTicsDropdownViewScrollHintLabelHeight, self.bounds.size.width, kNewTicsDropdownViewShowMoreButtonHeight);
        [self.showMoreButton setTitle:@"⌄" forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [self updateScrollHintLabelVisibility];
    }];
}

- (void)didTapShowMoreButton {
    self.isShowingFullView = !self.isShowingFullView;
    
    
    if (self.isShowingFullView) {
        [self showFullDropdownView];
    } else {
        [self showHalfDropdownView];
    }
    
}

- (void)showSameSenderNewTicsTableView {
    CGRect allNewTicsTableViewFrame = self.allNewTicsTableView.frame;
    allNewTicsTableViewFrame.origin.x = - self.bounds.size.width * 0.7;
    
    CGRect sameSenderNewTicsTableViewFrame = self.sameSenderNewTicsTableView.frame;
    sameSenderNewTicsTableViewFrame.origin.x = self.bounds.size.width * 0.3;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.allNewTicsTableView.frame = allNewTicsTableViewFrame;
        self.sameSenderNewTicsTableView.frame = sameSenderNewTicsTableViewFrame;
    }];
}

- (void)hideSameSenderNewTicsTableView {
    CGRect allNewTicsTableViewFrame = self.allNewTicsTableView.frame;
    allNewTicsTableViewFrame.origin.x = 0;
    
    CGRect sameSenderNewTicsTableViewFrame = self.sameSenderNewTicsTableView.frame;
    sameSenderNewTicsTableViewFrame.origin.x = self.bounds.size.width;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.allNewTicsTableView.frame = allNewTicsTableViewFrame;
        self.sameSenderNewTicsTableView.frame = sameSenderNewTicsTableViewFrame;
    }];
}


- (void)updateScrollHintLabelVisibility {
    if (self.isShowingTicsFromSameSender) {
        [self toggleScrollHintLabelVisibilityWithTableView:self.sameSenderNewTicsTableView];
    } else {
        [self toggleScrollHintLabelVisibilityWithTableView:self.allNewTicsTableView];
    }
}

- (void)toggleScrollHintLabelVisibilityWithTableView:(UITableView *)tableView {
    if (self.dataSource && [self.dataSource numberOfRowsInNewTicsDropdownViewTableView:tableView] > kNewTicsDropdownViewMaximumNumberOfRowsShown) {
        NSIndexPath *lastVisibleIndexPath = [[tableView indexPathsForVisibleRows] lastObject];
        if (lastVisibleIndexPath.row == [tableView numberOfRowsInSection:0] - 1) {
            if (self.isScrollHintLabelVisible) {
                self.isScrollHintLabelVisible = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    self.scrollHintLabel.alpha = 0.0;
                }];
            }
        } else {
            if (!self.isScrollHintLabelVisible) {
                self.isScrollHintLabelVisible = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    self.scrollHintLabel.alpha = 1.0;
                }];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource) {
        return [self.dataSource tableView:tableView cellForRowInNewTicsDropdownViewAtIndex:indexPath.row];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        return [self.dataSource numberOfRowsInNewTicsDropdownViewTableView:tableView];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TTNewTicsDropdownTableViewCell height];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate) {
        if ([self.delegate tableView:tableView shouldShowTicsFromSameSenderWhenNewTicsDropdownViewDidSelectRowAtIndex:indexPath.row]) {
            self.isShowingTicsFromSameSender = YES;
            if (self.isShowingFullView) {
                self.buttonsView.isShowingTicsFromSameSender = YES;
                [self showSameSenderNewTicsTableView];
                [UIView animateWithDuration:0.25 animations:^{
                    [self.buttonsView updateFrames];
                }];
            } else {
                [self showFullDropdownView];
            }
            NSLog(@"Dropdown view: show new table view");
        } else {
            NSLog(@"Dropdown view: show tic");
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateScrollHintLabelVisibility];
}


#pragma mark - TTUnreadTicsListSummaryViewDataSource

- (NSInteger)numberOfUnreadTics {
    if (self.dataSource) {
        return [self.dataSource numberOfUnreadTicsInNewTicsDropdownView];
    }
    return 0;
}

- (NSInteger)numberOfExpiredTics {
    if (self.dataSource) {
        return [self.dataSource numberOfExpiredTicsInNewTicsDropdownView];
    }
    return 0;
}


#pragma mark - TTNewTicsDropdownButtonsViewDelegate

- (void)newTicsDropdownButtonsViewDidTapBackButton {
    if (self.delegate) {
        [self.delegate newTicsDropdownViewDidTapBackButton];
    }
    
    self.isShowingTicsFromSameSender = NO;
    self.buttonsView.isShowingTicsFromSameSender = NO;
    [self hideSameSenderNewTicsTableView];
    [UIView animateWithDuration:0.25 animations:^{
        [self.buttonsView updateFrames];
    }];
}

- (void)newTicsDropdownButtonsViewDidTapClearAllExpiredTicsButton {
    if (self.delegate) {
        [self.delegate newTicsDropdownViewDidTapClearAllExpiredTicsButton];
    }
    
    [self.allNewTicsTableView reloadData];
    [self.sameSenderNewTicsTableView reloadData];
}

@end
