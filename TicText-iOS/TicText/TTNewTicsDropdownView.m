//
//  TTUnreadMessagesView.m
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTNewTicsDropdownView.h"

#import <PureLayout/PureLayout.h>

@interface TTNewTicsDropdownView ()

@property (nonatomic, assign) BOOL isScrollHintLabelVisible;

@property (nonatomic, strong) TTNewTicsDropdownSummaryView *summaryView;
@property (nonatomic, strong) UITableView *unreadTicsTableView;
@property (nonatomic, strong) UILabel *scrollHintLabel;

@property (nonatomic, strong) NSTimer *updateCellTimer;

@end

NSInteger const kUnreadTicsListViewMaximumNumberOfRowsShown = 5;
CGFloat const kUnreadTicsListViewScrollHintLabelHeight = 20;

@implementation TTNewTicsDropdownView

+ (CGFloat)height {
    return kUnreadTicsListViewMaximumNumberOfRowsShown * [TTNewTicsDropdownTableViewCell height] + kUnreadTicsListViewScrollHintLabelHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // summary view
        self.summaryView = [[TTNewTicsDropdownSummaryView alloc] initWithFrame:self.bounds];
        self.summaryView.dataSource = self;
        [self addSubview:self.summaryView];
        
        // table view
        self.unreadTicsTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.unreadTicsTableView.delegate = self;
        self.unreadTicsTableView.dataSource = self;
        self.unreadTicsTableView.clipsToBounds = YES;
        self.unreadTicsTableView.backgroundColor = [UIColor clearColor];
        self.unreadTicsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.unreadTicsTableView registerClass:[TTNewTicsDropdownTableViewCell class] forCellReuseIdentifier:[TTNewTicsDropdownTableViewCell reuseIdentifier]];
        [self.unreadTicsTableView reloadData];
        [self addSubview:self.unreadTicsTableView];
        
        // scroll hint label
        self.scrollHintLabel = [[UILabel alloc] init];
        self.scrollHintLabel.text = @"scroll up to view more...";
        self.scrollHintLabel.textAlignment = NSTextAlignmentLeft;
        self.scrollHintLabel.textColor = [UIColor whiteColor];
        self.scrollHintLabel.font = [UIFont fontWithName:kTTUIDefaultLightFont size:12];
        self.scrollHintLabel.alpha = 0.0;
        self.isScrollHintLabelVisible = NO;
        [self addSubview:self.scrollHintLabel];
        
        // background image
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"NewTicsDropdownViewBackground-%@w", @([UIScreen mainScreen].bounds.size.width)]]];
     }
    return self;
}

- (void)reloadData {
    if (self.dataSource) {
        self.summaryView.frame = CGRectMake(0, 0, (1- 0.618) * self.bounds.size.width, [TTNewTicsDropdownView height] - kUnreadTicsListViewScrollHintLabelHeight);
        self.unreadTicsTableView.frame = CGRectMake((1- 0.618) * self.bounds.size.width, 0, 0.618 * self.bounds.size.width, [TTNewTicsDropdownView height] - kUnreadTicsListViewScrollHintLabelHeight);
        self.scrollHintLabel.frame = CGRectMake(15 + (1- 0.618) * self.bounds.size.width, self.bounds.size.height - kUnreadTicsListViewScrollHintLabelHeight, self.bounds.size.width, kUnreadTicsListViewScrollHintLabelHeight);

        if ([self.dataSource numberOfRowsInNewTicsDropdownView] > kUnreadTicsListViewMaximumNumberOfRowsShown) {
            self.isScrollHintLabelVisible = YES;
            self.scrollHintLabel.alpha = 1.0;
        }
        
        if (self.updateCellTimer == nil) {
            self.updateCellTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateVisibleCells) userInfo:nil repeats:YES];
        }
        [self updateVisibleCells];
        [self.summaryView reloadData];
    }
    
    [self.unreadTicsTableView reloadData];
}

- (void)updateVisibleCells {
    for (NSIndexPath *indexPath in [self.unreadTicsTableView indexPathsForVisibleRows]) {
        TTNewTicsDropdownTableViewCell *currentCell = (TTNewTicsDropdownTableViewCell *)[self.unreadTicsTableView cellForRowAtIndexPath:indexPath];
        if ([currentCell isKindOfClass:[TTNewTicsDropdownTableViewCell class]]) {
            [currentCell updateTimeLeftLabel];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource) {
        return [self.dataSource unreadTicsListView:self cellForRowAtIndex:indexPath.row];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        return [self.dataSource numberOfRowsInNewTicsDropdownView];
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
        [self.delegate receivedNewTicsDropdownViewDidSelectNewTicAtIndex:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dataSource && [self.dataSource numberOfRowsInNewTicsDropdownView] > kUnreadTicsListViewMaximumNumberOfRowsShown) {
        NSIndexPath *lastVisibleIndexPath = [[self.unreadTicsTableView indexPathsForVisibleRows] lastObject];
        if (lastVisibleIndexPath.row == [self.unreadTicsTableView numberOfRowsInSection:0] - 1) {
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

@end
