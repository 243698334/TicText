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

- (void)presentLogInViewControllerAnimated:(BOOL)animated;

- (void)presentMainUserInterface;

@end


@interface TTRootViewControllerTests : XCTestCase

@property (nonatomic, strong) id mockRootViewController;

@end

@implementation TTRootViewControllerTests

- (void)setUp {
    [super setUp];
    self.mockRootViewController = OCMPartialMock([[TTRootViewController alloc] init]);
    [self.mockRootViewController viewDidLoad];
}

- (void)testSessionDidBecomeInvalid {
    // Arrange
    id mockSession = OCMPartialMock([TTSession sharedSession]);
    OCMStub([mockSession sharedSession]).andReturn(mockSession);
    OCMExpect([mockSession logOut:[OCMArg isKindOfClass:NSClassFromString(@"NSBlock")]]);
    OCMStub([mockSession logOut:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^logOutBlock)() = nil;
        [invocation getArgument:&logOutBlock atIndex:2];
        logOutBlock();
    });
    OCMExpect([self.mockRootViewController presentLogInViewControllerAnimated:[OCMArg any]]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTFacebookSessionDidBecomeInvalidNotification object:nil];
    
    // Assert
    OCMVerifyAll(mockSession);
    OCMVerifyAll(self.mockRootViewController);
}

- (void)testLogInViewControllerDidFinishLogIn {
    // Arrange
    id mockUtility = OCMClassMock([TTUtility class]);
    OCMExpect([mockUtility setupPushNotifications]);
    OCMExpect([self.mockRootViewController presentMainUserInterface]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTLogInViewControllerDidFinishLogInNotification object:nil];
    
    // Assert
    OCMVerifyAll(self.mockRootViewController);
}

- (void)testLogInViewControllerDidFinishSignUp {
    // Arrange
    id mockUtility = OCMClassMock([TTUtility class]);
    OCMExpect([mockUtility setupPushNotifications]);
    OCMExpect([self.mockRootViewController presentMainUserInterface]);
    OCMExpect([self.mockRootViewController presentViewController:[OCMArg isKindOfClass:[TTFindFriendsViewController class]] animated:[OCMArg any] completion:[OCMArg any]]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTLogInViewControllerDidFinishSignUpNotification object:nil];
    
    // Assert
    OCMVerifyAll(self.mockRootViewController);
}


- (void)testPresentMainUserInterface {
    // Arrange
    id mockTabBarController = OCMClassMock([UITabBarController class]);
    OCMStub([self.mockRootViewController tabBarController]).andReturn(mockTabBarController);
    OCMExpect([mockTabBarController setViewControllers:[OCMArg any]]);
    
    // Act
    [self.mockRootViewController presentMainUserInterface];
    
    // Assert
    OCMVerifyAll(mockTabBarController);
}

- (void)testUserDidLogOut {
    // Arrange
    id mockSession = OCMPartialMock([TTSession sharedSession]);
    OCMStub([mockSession sharedSession]).andReturn(mockSession);
    OCMExpect([mockSession logOut:[OCMArg isKindOfClass:NSClassFromString(@"NSBlock")]]);
    OCMStub([mockSession logOut:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^logOutBlock)() = nil;
        [invocation getArgument:&logOutBlock atIndex:2];
        logOutBlock();
    });
    id mockNavigationController = OCMClassMock([UINavigationController class]);
    OCMStub([self.mockRootViewController navigationController]).andReturn(mockNavigationController);
    OCMExpect([mockNavigationController popToRootViewControllerAnimated:[OCMArg any]]);
    
    // Act
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTUserDidLogOutNotification object:nil];
    
    
    // Assert
    OCMVerifyAll(mockSession);
    OCMVerifyAll(mockNavigationController);
}

@end
