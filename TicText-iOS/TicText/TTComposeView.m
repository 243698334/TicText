//
//  TTComposeView.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTComposeView.h"

#import <QuartzCore/QuartzCore.h>
#import "TTParallaxHeaderView.h"
#import "TTUser.h"

@interface TTComposeView ()

@property (nonatomic, strong) TTParallaxHeaderView *parallaxHeaderView;
@property (nonatomic, strong) UITableView *contactsTableView;

@property (nonatomic, strong) NSArray *contacts;

@end

@implementation TTComposeView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.parallaxHeaderView = [[TTParallaxHeaderView alloc] initWithTitle:@"Start Ticing with your friends" image:[UIImage imageNamed:@"ComposeHeader"] size:CGSizeMake(self.frame.size.width, self.frame.size.width * 0.375)];
        self.contactsTableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStyleGrouped];
        self.contactsTableView.delegate = self;
        self.contactsTableView.dataSource = self;
        self.contactsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contactsTableView setTableHeaderView:self.parallaxHeaderView];
        [self addSubview:self.contactsTableView];
        
        PFQuery *contactsQuery = [TTUser query];
        [contactsQuery fromPinWithName:kTTLocalDatastoreFriendsPinName];
        [contactsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.contacts = objects;
            [self.contactsTableView reloadData];
        }];
        [self.parallaxHeaderView refreshBluredImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.parallaxHeaderView refreshBluredImageView];

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate) {
        [self.delegate composeViewDidSelectContact:[self.contacts objectAtIndex:indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.contacts count]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ComposeTableViewCell"];
        cell.textLabel.text = @"Someone else";
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ComposeTableViewCell"];
    // TODO: use Jack's ContactsTableViewCell
    
    UIImage *profilePicture = [UIImage imageWithData:((TTUser *)[self.contacts objectAtIndex:indexPath.row]).profilePicture];
    CGRect imageViewFrame = cell.imageView.frame;
    cell.imageView.frame = imageViewFrame;
    cell.imageView.image = profilePicture;
    cell.imageView.layer.cornerRadius = 25;
    cell.imageView.clipsToBounds = YES;
    
    cell.textLabel.text = ((TTUser *)[self.contacts objectAtIndex:indexPath.row]).displayName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return [self.contacts count];
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
