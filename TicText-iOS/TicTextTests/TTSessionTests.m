//
//  TTSesionTests.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "TTHelper.h"
#import "TTSession.h"

@interface TTSessionTests : XCTestCase

@property (nonatomic, strong) id mockUser;

@end

@implementation TTSessionTests

- (void)setUp {
    [super setUp];
    
    self.mockUser = OCMClassMock([TTUser class]);
}

- (void)testIsUserLoggedInTrue {
    // Arrange
    OCMStub([self.mockUser currentUser]).andReturn([TTHelper fakeUser]);
    
    // Act
    BOOL isUserLoggedIn = [[[TTSession alloc] init] isUserLoggedIn];
    
    // Assert
    XCTAssertTrue(isUserLoggedIn);
}

- (void)testIsUserLoggedInFalse {
    // Arrange
    OCMStub([self.mockUser currentUser]).andReturn(nil);
    
    // Act
    BOOL isUserLoggedIn = [[[TTSession alloc] init] isUserLoggedIn];
    
    // Assert
    XCTAssertFalse(isUserLoggedIn);
}

- (void)testLogout {
    // Arrange
    OCMExpect([self.mockUser logOut]);
    
    // Act
    [[[TTSession alloc] init] logout:nil];
    
    // Assert
    OCMVerifyAll(self.mockUser);
}

@end
