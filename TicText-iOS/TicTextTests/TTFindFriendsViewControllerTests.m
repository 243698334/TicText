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
@property (nonatomic, strong) TTFindFriendsViewController *mockVC;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FindFriendsTableViewCell *firstCell;
@property (nonatomic, strong) FindFriendsTableViewCell *secondCell;
@end

@implementation FindFriendsViewControllerTests

- (void)setUp {
    [super setUp];
    self.mockVC = OCMPartialMock([[TTFindFriendsViewController alloc] init]);
}

-(void)testTableViewLoadedOnScreen {
    OCMVerify([self.mockVC isKindOfClass:[TTFindFriendsViewController class]]);
    NSArray *subviews = [self.mockVC.view subviews];
    
    OCMVerify(subviews.count > 0); //make sure there is something on the view controller
    
    self.tableView = subviews[0];

    OCMVerify(self.tableView != nil); //make sure the tableview is on the view controller
}

-(void)testTableViewAttributes {
    
    OCMVerify(self.tableView.numberOfSections == 1); //make sure one section
    OCMVerify([self.tableView numberOfRowsInSection:0] == 25); //make sure 25 rows
    
    UIView *view = [self.tableView headerViewForSection:0];
    OCMVerify(view != nil); //verify has a header
    NSArray *subviews = [view subviews];
    UIImageView *iv = nil;
    
    for(UIView *view in subviews) {
        UIView *v = OCMPartialMock(view);
        if([v isKindOfClass:[UIImageView class]]) {
            iv = v;
        }
    }
    
    OCMVerify(iv != nil); //make sure there's an image on the section header
    
    for(int i = 0; i<25; i++) {
        OCMVerify([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] class] == [FindFriendsTableViewCell class]); //make sure all cells are of FindFriendsTableViewCell
    }
    
    self.firstCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.secondCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
}

-(void)testFirstCell {
    NSArray *subviews = [self.firstCell subviews];
    OCMVerify(subviews.count == 3); //make sure only 3 cells show up
    
    for(UIView *view in subviews) {
        UIView *v = OCMPartialMock(view);
        OCMVerify([v isKindOfClass:[UIImageView class]]); //make sure only images are shown on cell
    }
}

-(void)testSecondCell {
    NSArray *subviews = [self.secondCell subviews];
    OCMVerify(subviews.count == 2); //make sure only 2 pictures show up
    for(UIView *view in subviews) {
        UIView *v = OCMPartialMock(view);
        OCMVerify([v isKindOfClass:[UIImageView class]]); //make sure only images are shown on cell
    }

}
@end
