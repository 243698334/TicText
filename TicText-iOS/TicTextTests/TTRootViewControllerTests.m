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

@property (nonatomic, strong) TTRootViewController *mockVC;

@end

@implementation TTRootViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.mockVC = OCMPartialMock([[TTRootViewController alloc] init]);
}

/*- (void)testPresentLogInViewControllerIfNeededTrue {
    // Arrange
    id mockSession = OCMClassMock([TTSession class]);
    OCMStub([mockSession sharedSession]).andReturn(mockSession);
    OCMExpect([mockSession isUserLoggedIn]);
    
    // Act
    [[[TTRootViewController alloc] init] logout:nil];
    
    // Assert
    OCMVerifyAll(mockSession);
}*/

- (void)testPresentLogInViewController {
    // Arrange
    BOOL presentForLogIn = YES;
    BOOL animated = NO;
    
    // Act
    [self.mockVC presentLogInViewControllerForLogIn:presentForLogIn animated:animated];
    
    // Assert
    OCMVerify([self.mockVC presentViewController:[OCMArg isKindOfClass:[TTLogInViewController class]] animated:animated completion:[OCMArg any]]);
}

- (void)testLogout {
    // Arrange
    id mockSession = OCMClassMock([TTSession class]);
    OCMStub([mockSession sharedSession]).andReturn(mockSession);
    OCMExpect([mockSession logout:[OCMArg any]]);
    
    // Act
    [[[TTRootViewController alloc] init] logout:nil];
    
    // Assert
    OCMVerifyAll(mockSession);
}

- (void)testViewDidAppear {
    // Arrange
    
    // Act
    [self.mockVC viewDidAppear:NO];
    
    // Assert
    OCMVerify([self.mockVC presentLogInViewControllerIfNeeded]);
}

@end
