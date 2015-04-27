//
//  TTUnreadMessagesView.m
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTUnreadTicsListView.h"

#import <PureLayout/PureLayout.h>
#import "TTConstants.h"

@interface TTUnreadTicsListView ()

@property (nonatomic, assign) BOOL isScrollHintLabelVisible;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *scrollHintLabel;

@property (nonatomic, strong) NSTimer *updateCellTimer;

@end

NSInteger const kUnreadTicsListViewMaximumNumberOfRowsShown = 5;
CGFloat const kUnreadTicsListViewScrollHintLabelHeight = 20;

@implementation TTUnreadTicsListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // table view
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.clipsToBounds = YES;
        self.tableView.backgroundColor = kTTUIPurpleColor;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView registerClass:[TTUnreadTicsListTableViewCell class] forCellReuseIdentifier:[TTUnreadTicsListTableViewCell reuseIdentifier]];
        [self.tableView reloadData];
        [self addSubview:self.tableView];
        [self bringSubviewToFront:self.tableView];
        
        // scroll hint label
        self.scrollHintLabel = [[UILabel alloc] init];
        self.scrollHintLabel.text = @"scroll up to view more...";
        self.scrollHintLabel.textAlignment = NSTextAlignmentLeft;
        self.scrollHintLabel.textColor = [UIColor whiteColor];
        self.scrollHintLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12];
        self.isScrollHintLabelVisible = NO;
    }
    return self;
}

- (CGFloat)requiredHeight {
    if (self.dataSource) {
        NSInteger numberOfRows = [self.dataSource numberOfRowsInUnreadTicsList];
        if (numberOfRows > kUnreadTicsListViewMaximumNumberOfRowsShown) {
            return kUnreadTicsListViewMaximumNumberOfRowsShown * [TTUnreadTicsListTableViewCell height] + kUnreadTicsListViewScrollHintLabelHeight;
        } else {
            return numberOfRows * [TTUnreadTicsListTableViewCell height];
        }
    } else {
        return 0.0;
    }
}

- (void)reloadData {
    if (self.dataSource) {
        NSInteger numberOfRows = [self.dataSource numberOfRowsInUnreadTicsList];
        if (numberOfRows > kUnreadTicsListViewMaximumNumberOfRowsShown) {
            self.scrollHintLabel.frame = CGRectMake(15, self.bounds.size.height - kUnreadTicsListViewScrollHintLabelHeight, self.bounds.size.width, kUnreadTicsListViewScrollHintLabelHeight);
            [self addSubview:self.scrollHintLabel];
            [self bringSubviewToFront:self.scrollHintLabel];
            self.isScrollHintLabelVisible = YES;
        }
        NSInteger numberOfRowsShown = numberOfRows > kUnreadTicsListViewMaximumNumberOfRowsShown ? kUnreadTicsListViewMaximumNumberOfRowsShown : numberOfRows;
        self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, numberOfRowsShown * [TTUnreadTicsListTableViewCell height]);
        if (self.updateCellTimer == nil) {
            self.updateCellTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateVisibleCells) userInfo:nil repeats:YES];
        }
        [self updateVisibleCells];
    }
    
    [self.tableView reloadData];
}

- (void)updateVisibleCells {
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        TTUnreadTicsListTableViewCell *currentCell = (TTUnreadTicsListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([currentCell isKindOfClass:[TTUnreadTicsListTableViewCell class]]) {
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
        return [self.dataSource numberOfRowsInUnreadTicsList];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TTUnreadTicsListTableViewCell height];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate) {
        [self.delegate unreadTicsListViewDidSelectUnreadTicAtIndex:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dataSource && [self.dataSource numberOfRowsInUnreadTicsList] > kUnreadTicsListViewMaximumNumberOfRowsShown) {
        NSIndexPath *lastVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
        if (lastVisibleIndexPath.row == [self.tableView numberOfRowsInSection:0] - 1) {
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

@end
