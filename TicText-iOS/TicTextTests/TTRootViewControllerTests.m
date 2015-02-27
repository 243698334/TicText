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

@interface TTRootViewController (Test)

- (void) presentLogInViewControllerAnimated:(BOOL)animated;

@end

@interface TTRootViewControllerTests : XCTestCase

@property (nonatomic, strong) id mockRootViewController;

@end

@implementation TTRootViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.mockRootViewController = OCMPartialMock([[TTRootViewController alloc] init]);
}

- (void)testSessionDidBecomeInvalid {
    // Arrange
    id mockSession = OCMPartialMock([TTSession sharedSession]);
    OCMStub([mockSession sharedSession]).andReturn(mockSession);
    
    // keep or comment
    OCMExpect([mockSession logOut:[OCMArg isKindOfClass:NSClassFromString(@"NSBlock")]]);
    OCMStub([mockSession logOut:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^logOutBlock)() = nil;
        [invocation getArgument:&logOutBlock atIndex:2];
        logOutBlock();
    });
    
    // Goal
    OCMExpect([self.mockRootViewController presentLogInViewControllerAnimated:[OCMArg any]]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTFacebookSessionDidBecomeInvalidNotification object:nil];
    
    // Assert
    OCMVerifyAll(mockSession);
    OCMVerifyAll(self.mockRootViewController);
}


@end
