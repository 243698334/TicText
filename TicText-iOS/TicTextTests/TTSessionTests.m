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

#import "TTHelper.h"
#import "TTSession.h"

@interface TTSessionTests : XCTestCase

@property (nonatomic, strong) id mockSession;

@end

@implementation TTSessionTests

- (void)setUp {
    [super setUp];
    self.mockSession = OCMClassMock([TTSession class]);
}

- (void)testIsValidLastChecked {
    // Arrange
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults boolForKey:kTTParseSessionIsValidLastCheckedKey]).andReturn(YES);
    OCMStub([mockUserDefaults boolForKey:kTTFacebookSessionIsValidLastCheckedKey]).andReturn(NO);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([self.mockSession isValidLastChecked]);
    
    // Act
    BOOL result = [[TTSession sharedSession] isValidLastChecked];
    
    // Assert
    OCMVerifyAll(mockUserDefaults);
    XCTAssertFalse(result);
}

- (void)testValidateSessionInBackground {
    // Arrange
    id mockUser = OCMClassMock([TTUser class]);
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    // Parse local session INVALID
    OCMStub([mockUser currentUser]).andReturn(nil);
    OCMExpect([mockNotificationCenter postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey]);
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testLogIn {
    // Arrange
    OCMExpect([self.mockSession logIn:[OCMArg any]]);
    OCMStub([self.mockSession sharedSession]).andReturn(self.mockSession);
    
    // Act
    [[TTSession sharedSession] logIn:nil];
    
    // Assert
    OCMVerifyAll(self.mockSession);
}

- (void)testLogOut {
    // Arrange
    OCMExpect([self.mockSession logOut:[OCMArg any]]);
    OCMStub([self.mockSession sharedSession]).andReturn(self.mockSession);
    
    // Act
    [[TTSession sharedSession] logOut:nil];
    
    // Assert
    OCMVerifyAll(self.mockSession);
}

@end
