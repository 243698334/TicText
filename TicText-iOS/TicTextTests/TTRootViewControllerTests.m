//
//  TTRootViewControllerTests.m
//  TicText
//
//  Created by Terrence K on 2/21/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "TTRootViewController.h"
#import "TTLogInViewController.h"
#import "TTSession.h"

@interface TTRootViewControllerTests : XCTestCase

@property (nonatomic, strong) TTRootViewController *mockRootViewController;

@end

@implementation TTRootViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.mockRootViewController = OCMPartialMock([[TTRootViewController alloc] init]);
}

- (void)testPresentLogInViewController {
    // Arrange
    BOOL animated = NO;
    
    // Act
    [self.mockRootViewController presentLogInViewControllerAnimated:animated];
    
    // Assert
    OCMVerify([self.mockRootViewController presentViewController:[OCMArg isKindOfClass:[TTLogInViewController class]] animated:animated completion:[OCMArg any]]);
}



@end
