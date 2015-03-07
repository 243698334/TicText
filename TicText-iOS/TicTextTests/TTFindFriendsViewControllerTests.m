//
//  FindFriendsViewControllerTests.m
//  TicText
//
//  Created by Jack Arendt on 2/24/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TTFindFriendsViewController.h"
#import "FindFriendsTableViewCell.h"

@interface FindFriendsViewControllerTests : XCTestCase
@property (nonatomic, strong) TTFindFriendsViewController *viewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FindFriendsTableViewCell *firstCell;
@property (nonatomic, strong) FindFriendsTableViewCell *secondCell;
@end

@implementation FindFriendsViewControllerTests

- (void)setUp {
    [super setUp];
    self.viewController = [[TTFindFriendsViewController alloc] init];
    [self.viewController viewDidLoad];
    
    NSArray *subviews = [self.viewController.view subviews];
    self.tableView = subviews[0];
    self.firstCell = (FindFriendsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.secondCell = (FindFriendsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
}

-(void)testTableViewLoadedOnScreen {
    XCTAssertTrue([self.viewController isKindOfClass:[TTFindFriendsViewController class]]);
    XCTAssertTrue(self.tableView != nil); //make sure the tableview is on the view controller
}

-(void)testTableViewAttributes {
    XCTAssertTrue([self.tableView numberOfSections] == 1); //make sure one section
//    XCTAssertTrue([self.tableView numberOfRowsInSection:0] == 25); //make sure 25 rows
    
    UIView *view = [self.viewController tableView:self.tableView viewForHeaderInSection:0];
    XCTAssertTrue(view != nil); //verify has a header
    NSArray *subviews = [view subviews];
    UIImageView *iv = nil;
    
    for(UIView *view in subviews) {
        UIView *v = OCMPartialMock(view);
        if([v isKindOfClass:[UIImageView class]]) {
            iv = (UIImageView *)v;
        }
    }
    
    XCTAssertTrue(iv != nil); //make sure there's an image on the section header
    
    for(NSIndexPath *index in [self.tableView indexPathsForVisibleRows]) {
        NSInteger i = index.row;
        XCTAssertTrue([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] class] == [FindFriendsTableViewCell class]); //make sure all cells are of FindFriendsTableViewCell
    }
}

-(void)testFirstCell {
    NSArray *subviews = [self.firstCell subviews];
    for(int i = 1; i < subviews.count; i++) {
        UIView *view = subviews[i];
        XCTAssertTrue([view isKindOfClass:[UIImageView class]]); //make sure only images are shown on cell
    }
}

-(void)testSecondCell {
    NSArray *subviews = [self.secondCell subviews];
    for(int i = 1; i < subviews.count; i++) {
        UIView *view = subviews[i];
        XCTAssertTrue([view isKindOfClass:[UIImageView class]]); //make sure only images are shown on cell
    }

}
@end
