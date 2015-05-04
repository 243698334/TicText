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

#import "TTConstants.h"
#import "TTTestHelper.h"
#import "TTSession.h"
#import "TTUtility.h"
#import "TTUser.h"

@interface TTSessionTests : XCTestCase

@property (nonatomic, strong) id mockSession;
@property (nonatomic, strong) id mockUtility;
@property (nonatomic, strong) id mockUser;
@property (nonatomic, strong) id mockUserPrivateData;

@end

@implementation TTSessionTests

- (void)setUp {
//    [super setUp];
//    self.mockSession = OCMPartialMock([[TTSession alloc] init]);
//    self.mockUser = OCMClassMock([TTUser class]);
//    self.mockUserPrivateData = OCMClassMock([TTUserPrivateData class]);
//    self.mockUtility = OCMClassMock([TTUtility class]);
//    OCMStub([self.mockUtility isParseReachable]).andReturn(YES);
//    OCMStub([self.mockUtility isInternetReachable]).andReturn(YES);
//    OCMStub([self.mockUser privateData]).andReturn(self.mockUserPrivateData);
}

- (void)testIsValidLastChecked {
//    // Arrange
//    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
//    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
//    OCMStub([mockUserDefaults boolForKey:kTTUserDefaultsSessionIsValidLastCheckedKey]).andReturn(NO);
//    OCMExpect([self.mockSession isValidLastChecked]);
//    
//    // Act
//    BOOL result = [TTSession isValidLastChecked];
//    
//    // Assert
//    OCMVerifyAll(self.mockSession);
//    OCMVerifyAll(mockUserDefaults);
//    XCTAssertFalse(result);
}

- (void)testValidateSessionInBackgroundParseLocalSessionInvalid {
//    // Arrange
//    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
//    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
//    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
//    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
//    
//    // Parse local session INVALID (user not logged in)
//    OCMStub([self.mockUser currentUser]).andReturn(nil);
//    OCMExpect([mockNotificationCenter postNotificationName:kTTSessionDidBecomeInvalidNotification object:nil]);
//    OCMExpect([mockUserDefaults setBool:NO forKey:kTTUserDefaultsSessionIsValidLastCheckedKey]);
//    
//    // Act
//    [TTSession validateSessionInBackground];
//    
//    // Assert
//    OCMVerifyAll(mockNotificationCenter);
//    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseRemoteSessionFetchFailure {
//    // Arrange
//    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
//    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
//    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
//    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
//    OCMExpect([mockNotificationCenter postNotificationName:kTTSessionDidBecomeInvalidNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
//        NSDictionary *userInfo = (NSDictionary *)obj;
//        NSError *error = [userInfo objectForKey:kTTNotificationUserInfoErrorKey];
//        return [error.domain isEqualToString:kTTSessionErrorDomain];
//    }]]);
//    OCMExpect([mockUserDefaults setBool:NO forKey:kTTUserDefaultsSessionIsValidLastCheckedKey]);
//    
//    // Parse local session VALID
//    OCMStub([self.mockUser currentUser]).andReturn(self.mockUser);
//    
//    // Parse remote session INVALID (fetch failure)
//    OCMStub([self.mockUserPrivateData fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
//        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
//        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
//        NSError *fakeError = [NSError errorWithDomain:@"fakeDomain" code:0 userInfo:nil];
//        fetchInBackgroundBlock(self.mockUserPrivateData, fakeError);
//    });
//    
//    // Act
//    [TTSession validateSessionInBackground];
//    
//    // Assert
//    OCMVerifyAll(mockNotificationCenter);
//    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseRemoteSessionInvalidUUID {
//    // Arrange
//    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
//    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
//    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
//    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
//    OCMExpect([mockNotificationCenter postNotificationName:kTTSessionDidBecomeInvalidNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
//        NSDictionary *userInfo = (NSDictionary *)obj;
//        NSError *error = [userInfo objectForKey:kTTNotificationUserInfoErrorKey];
//        return [error.domain isEqualToString:kTTSessionErrorDomain] && error.code == kTTSessionErrorParseSessionInvalidUUIDCode;
//    }]]);
//    OCMExpect([mockUserDefaults setBool:NO forKey:kTTUserDefaultsSessionIsValidLastCheckedKey]);
//    
//    // Parse local session VALID
//    OCMStub([self.mockUser currentUser]).andReturn(self.mockUser);
//    
//    // Parse remote session INVALID (invalid UUID)
//    OCMStub([self.mockUserPrivateData activeDeviceIdentifier]).andReturn(@"fakeDeviceIdentifier");
//    OCMStub([self.mockUserPrivateData fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
//        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
//        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
//        fetchInBackgroundBlock(self.mockUserPrivateData, nil);
//    });
//    
//    // Act
//    [TTSession validateSessionInBackground];
//    
//    // Assert
//    OCMVerifyAll(mockNotificationCenter);
//    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseSessionValid {
//    // Arrange
//    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
//    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
//    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
//    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
//    OCMExpect([mockUserDefaults setBool:YES forKey:kTTUserDefaultsSessionIsValidLastCheckedKey]);
//    
//    // Parse local session VALID
//    OCMStub([self.mockUser currentUser]).andReturn(self.mockUser);
//    
//    // Parse remote session VALID
//    OCMStub([self.mockUserPrivateData activeDeviceIdentifier]).andReturn([UIDevice currentDevice].identifierForVendor.UUIDString);
//    OCMStub([self.mockUserPrivateData fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
//        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
//        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
//        fetchInBackgroundBlock(self.mockUserPrivateData, nil);
//    });
//    
//    // Act
//    [TTSession validateSessionInBackground];
//    
//    // Assert
//    OCMVerifyAll(mockNotificationCenter);
//    OCMVerifyAll(mockUserDefaults);
}

- (void)testLogIn {
//    // Arrange
//    OCMExpect([self.mockSession logInWithBlock:[OCMArg any]]);
//
//    // Act
//    [TTSession logInWithBlock:[OCMArg any]];
//    
//    // Assert
//    OCMVerifyAll(self.mockSession);
}

- (void)testLogOut {
//    // Arrange
//    OCMExpect([self.mockSession logOutWithBlock:[OCMArg any]]);
//    
//    // Act
//    [TTSession logOutWithBlock:[OCMArg any]];
//    
//    // Assert
//    OCMVerifyAll(self.mockSession);
}

@end
