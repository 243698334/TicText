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

@property (nonatomic, strong) id mockRootViewController;

@end

@implementation TTRootViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.mockRootViewController = OCMPartialMock([[TTRootViewController alloc] init]);
}

//- (void)testSessionDidBecomeInvalid {
//    // Arrange
//    id mockSession = OCMPartialMock([TTSession sharedSession]);
//    OCMStub([mockSession sharedSession]).andReturn(mockSession);
//    OCMExpect([mockSession logOut:[OCMArg isKindOfClass:NSClassFromString(@"NSBlock")]]);
//    id mockNavigationController = OCMClassMock([UINavigationController class]);
//    //OCMExpect([mockNavigationController popToRootViewControllerAnimated:[OCMArg any]]);
//    OCMStub(((TTRootViewController *)self.mockRootViewController).navigationController).andReturn(mockNavigationController);
//    OCMStub([self.mockRootViewController navigationController]).andReturn(mockNavigationController);
//    OCMStub([mockSession logOut:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
//        void (^logOutBlock)() = nil;
//        [invocation getArgument:&logOutBlock atIndex:2];
//        logOutBlock();
//    });
//    
//    // Act
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTTFacebookSessionDidBecomeInvalidNotification object:nil];
//    
//    // Assert
//    OCMVerifyAll(mockSession);
//    OCMVerify(((TTRootViewController *)self.mockRootViewController).logIn);
//    //OCMVerifyAll(mockNavigationController);
//}


@end
