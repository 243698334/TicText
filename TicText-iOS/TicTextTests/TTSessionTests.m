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

#import "TTTestHelper.h"
#import "TTSession.h"

@interface TTSessionTests : XCTestCase

@property (nonatomic, strong) id mockSession;
@property (nonatomic, strong) id mockUser;
@property (nonatomic, strong) id mockUserPrivateData;
@property (nonatomic, strong) id mockReachability;

@end

@implementation TTSessionTests

- (void)setUp {
    [super setUp];
    self.mockSession = OCMPartialMock([[TTSession alloc] init]);
    self.mockUser = OCMClassMock([TTUser class]);
    self.mockUserPrivateData = OCMClassMock([TTUserPrivateData class]);
    self.mockReachability = OCMClassMock([Reachability class]);
    OCMStub([self.mockSession sharedSession]).andReturn(self.mockSession);
    OCMStub([self.mockSession isParseServerReachable]).andReturn(YES);
    OCMStub([self.mockUser privateData]).andReturn(self.mockUserPrivateData);
    OCMStub([self.mockReachability reachabilityForInternetConnection]).andReturn(self.mockReachability);
    OCMStub([self.mockReachability reachabilityWithHostName:[OCMArg any]]).andReturn(self.mockReachability);
    OCMStub([self.mockReachability startNotifier]);
    OCMStub([self.mockReachability currentReachabilityStatus]).andReturn(ReachableViaWiFi);
}

- (void)testIsValidLastChecked {
    // Arrange
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMStub([mockUserDefaults boolForKey:kTTSessionIsValidLastCheckedKey]).andReturn(NO);
    OCMExpect([self.mockSession isValidLastChecked]);
    
    // Act
    BOOL result = [[TTSession sharedSession] isValidLastChecked];
    
    // Assert
    OCMVerifyAll(self.mockSession);
    OCMVerifyAll(mockUserDefaults);
    XCTAssertFalse(result);
}

- (void)testValidateSessionInBackgroundParseLocalSessionInvalid {
    // Arrange
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    
    // Parse local session INVALID (user not logged in)
    OCMStub([self.mockUser currentUser]).andReturn(nil);
    OCMExpect([mockNotificationCenter postNotificationName:kTTSessionDidBecomeInvalidNotification object:nil]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTSessionIsValidLastCheckedKey]);
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseRemoteSessionFetchFailure {
    // Arrange
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([mockNotificationCenter postNotificationName:kTTSessionDidBecomeInvalidNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSDictionary *userInfo = (NSDictionary *)obj;
        NSError *error = [userInfo objectForKey:kTTNotificationUserInfoErrorKey];
        return [error.domain isEqualToString:kTTSessionErrorDomain] && error.code == kTTSessionErrorParseSessionFetchFailureCode;
    }]]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTSessionIsValidLastCheckedKey]);
    
    // Parse local session VALID
    OCMStub([self.mockUser currentUser]).andReturn(self.mockUser);
    
    // Parse remote session INVALID (fetch failure)
    OCMStub([self.mockUserPrivateData fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
        NSError *fakeError = [NSError errorWithDomain:@"fakeDomain" code:0 userInfo:nil];
        fetchInBackgroundBlock(self.mockUserPrivateData, fakeError);
    });
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseRemoteSessionInvalidUUID {
    // Arrange
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([mockNotificationCenter postNotificationName:kTTSessionDidBecomeInvalidNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSDictionary *userInfo = (NSDictionary *)obj;
        NSError *error = [userInfo objectForKey:kTTNotificationUserInfoErrorKey];
        return [error.domain isEqualToString:kTTSessionErrorDomain] && error.code == kTTSessionErrorParseSessionInvalidUUIDCode;
    }]]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTSessionIsValidLastCheckedKey]);
    
    // Parse local session VALID
    OCMStub([self.mockUser currentUser]).andReturn(self.mockUser);
    
    // Parse remote session INVALID (invalid UUID)
    OCMStub([self.mockUserPrivateData activeDeviceIdentifier]).andReturn(@"fakeDeviceIdentifier");
    OCMStub([self.mockUserPrivateData fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
        fetchInBackgroundBlock(self.mockUserPrivateData, nil);
    });
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseSessionValid {
    // Arrange
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([mockUserDefaults setBool:YES forKey:kTTSessionIsValidLastCheckedKey]);
    
    // Parse local session VALID
    OCMStub([self.mockUser currentUser]).andReturn(self.mockUser);
    
    // Parse remote session VALID
    OCMStub([self.mockUserPrivateData activeDeviceIdentifier]).andReturn([UIDevice currentDevice].identifierForVendor.UUIDString);
    OCMStub([self.mockUserPrivateData fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
        fetchInBackgroundBlock(self.mockUserPrivateData, nil);
    });
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testLogIn {
    // Arrange
    OCMExpect([self.mockSession logIn:[OCMArg any]]);

    // Act
    [[TTSession sharedSession] logIn:nil];
    
    // Assert
    OCMVerifyAll(self.mockSession);
}

- (void)testLogOut {
    // Arrange
    OCMExpect([self.mockSession logOut:[OCMArg any]]);
    
    // Act
    [[TTSession sharedSession] logOut:nil];
    
    // Assert
    OCMVerifyAll(self.mockSession);
}

@end
