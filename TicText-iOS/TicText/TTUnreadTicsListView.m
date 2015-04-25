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

@property (nonatomic, assign) BOOL addedConstraints;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *scrollHintLabel;

@property (nonatomic, assign) CGRect expandedFrame;
@property (nonatomic, assign) CGRect collapsedFrame;

@end

NSInteger const kUnreadTicsListViewMaximumNumberOfUnreadTicsShown = 5;
CGFloat const kUnreadTicsListViewScrollHintLabelHeight = 5;

@implementation TTUnreadTicsListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // scroll view
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        //[self addSubview:self.scrollView];
        
        // table view
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.clipsToBounds = YES;
        [self.tableView registerClass:[TTUnreadTicsListTableViewCell class] forCellReuseIdentifier:[TTUnreadTicsListTableViewCell reuseIdentifier]];
        //[self.scrollView addSubview:self.tableView];
        [self addSubview:self.tableView];
        [self bringSubviewToFront:self.tableView];
        
        // scroll hint label
        self.scrollHintLabel = [[UILabel alloc] init];
        self.scrollHintLabel.text = @"scroll up to view more...";
        self.scrollHintLabel.textAlignment = NSTextAlignmentRight;
        
        // expanded/collapsed frames
        self.expandedFrame = frame;
        frame.size.height = 0;
        self.collapsedFrame = frame;
        
    }
    return self;
}

- (CGRect)lowerFrame:(CGRect)frame {
    frame.origin.y += CGRectGetHeight(self.expandedFrame);
    return frame;
}

- (CGRect)raiseFrame:(CGRect)frame {
    frame.origin.y -= CGRectGetHeight(self.expandedFrame);
    return frame;
}

- (void)collapse {
    if (CGRectEqualToRect(self.frame, self.collapsedFrame)) return;
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView* view in self.superview.subviews) {
            if (CGRectGetMinY(view.frame) > CGRectGetMaxY(self.frame))
                view.frame = [self raiseFrame:view.frame];
        }
        self.frame = self.collapsedFrame;
    }];
}

- (void)expand {
    if (CGRectEqualToRect(self.frame, self.expandedFrame)) return;
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView* view in self.superview.subviews) {
            if (CGRectGetMinY(view.frame) > CGRectGetMaxY(self.frame))
                view.frame = [self lowerFrame:view.frame];
        }
        self.frame = self.expandedFrame;
    }];
}

- (void)toggle {
    if (CGRectEqualToRect(self.frame, self.collapsedFrame))
        [self expand];
    else [self collapse];
}

- (void)reloadData {
    // set constraints based on number of rows
    if (self.dataSource) {
        if ([self.dataSource numberOfRowsInUnreadTicsList] > kUnreadTicsListViewMaximumNumberOfUnreadTicsShown) {
            CGRect maximumHeightFrame = self.frame;
            maximumHeightFrame.size.height = kUnreadTicsListViewScrollHintLabelHeight * [TTUnreadTicsListTableViewCell height] + kUnreadTicsListViewScrollHintLabelHeight;
            self.frame = maximumHeightFrame;
            
            [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
            [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.scrollHintLabel autoSetDimension:ALDimensionHeight toSize:kUnreadTicsListViewScrollHintLabelHeight];
            [self.scrollHintLabel autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width];
            [self addSubview:self.scrollHintLabel];
        } else {
            //[self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            //[self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
    [self.tableView reloadData];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate) {
        [self.delegate unreadTicsListViewDidSelectUnreadTicAtIndex:indexPath.row];
    }
}

@end
