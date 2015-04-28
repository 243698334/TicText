//
//  TTComposeView.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTComposeView.h"

#import <QuartzCore/QuartzCore.h>
#import <PureLayout/PureLayout.h>
#import "TTUtility.h"
#import "TTParallaxHeaderView.h"
#import "TTComposeTableViewCell.h"
#import "TTUser.h"

@interface TTComposeView ()

@property (nonatomic, assign) BOOL addedConstraints;

@property (nonatomic, strong) TTParallaxHeaderView *parallaxHeaderView;
@property (nonatomic, strong) UITableView *contactsTableView;

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic) BOOL anonymous;
@end

@implementation TTComposeView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.addedConstraints = NO;
        
        self.parallaxHeaderView = [[TTParallaxHeaderView alloc] initWithTitle:@"Start Ticing with your friends" image:[UIImage imageNamed:@"ComposeHeader"] size:CGSizeMake(self.frame.size.width, self.frame.size.width * 0.375)];
        self.contactsTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        self.contactsTableView.delegate = self;
        self.contactsTableView.dataSource = self;
        self.contactsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contactsTableView setTableHeaderView:self.parallaxHeaderView];
        [self.contactsTableView registerClass:[TTComposeTableViewCell class] forCellReuseIdentifier:[TTComposeTableViewCell reuseIdentifier]];
        [self addSubview:self.contactsTableView];
        
        self.friends = [TTUser currentUser].privateData.friends;
        
//        [TTUser fetchAllIfNeededInBackground:[TTUser currentUser].privateData.friends block:^(NSArray *objects, NSError *error) {
//            self.friends = objects;
//            self.anonymous = NO; // TODO: add a toggle on UI to set this property
//            [self.contactsTableView reloadData];
//        }];
        [self.parallaxHeaderView refreshBluredImageView];
    }
    return self;
}

- (void)loadFriendsData {
    if ([TTUtility isParseReachable]) {
        [TTUser fetchAllIfNeededInBackground:[TTUser currentUser].privateData.friends block:^(NSArray *objects, NSError *error) {
            self.friends = objects;
            self.anonymous = NO; // TODO: add a toggle on UI to set this property
            [self.contactsTableView reloadData];
        }];
    } else {
        self.friends = [TTUser currentUser].privateData.friends;
        self.anonymous = NO; // TODO: add a toggle on UI to set this property
        [self.contactsTableView reloadData];
    }
}

- (void)reloadData {
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!self.addedConstraints) {
        [self.contactsTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        self.addedConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.parallaxHeaderView refreshBluredImageView];

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate) {
        [self.delegate composeViewDidSelectContact:[self.friends objectAtIndex:indexPath.row] anonymous:self.anonymous];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TTComposeTableViewCell height];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTUser *currentContact = (TTUser *)[self.friends objectAtIndex:indexPath.row];
    TTComposeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TTComposeTableViewCell reuseIdentifier] forIndexPath:indexPath];
    [cell updateWithUser:currentContact];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return [self.friends count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contactsTableView) {
        [self.parallaxHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}

@end
