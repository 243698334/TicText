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
    self.mockSession = OCMPartialMock([TTSession sharedSession]);
    OCMStub([self.mockSession sharedSession]).andReturn(self.mockSession);
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

- (void)testValidateSessionInBackgroundParseLocalSession {
    // Arrange
    id mockUser = OCMClassMock([TTUser class]);
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    // Parse local session INVALID (user not logged in)
    OCMStub([mockUser currentUser]).andReturn(nil);
    OCMExpect([mockNotificationCenter postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey]);
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseRemoteSessionFetchFailure {
    // Arrange
    id mockUser = OCMClassMock([TTUser class]);
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([mockNotificationCenter postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSDictionary *userInfo = (NSDictionary *)obj;
        NSError *error = [userInfo objectForKey:kTTErrorUserInfoKey];
        return [error.domain isEqualToString:kTTSessionErrorDomain] && error.code == kTTSessionErrorParseSessionFetchFailureCode;
    }]]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey]);
    
    // Parse local session VALID
    OCMStub(([mockUser currentUser])).andReturn(mockUser);
    
    // Parse remote session INVALID (fetchInBackground error)
    OCMStub([mockUser fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [OCMArg any]};
        NSError *error = [NSError errorWithDomain:@"Fake Domain" code:1 userInfo:userInfo];
        fetchInBackgroundBlock(mockUser, error);
    });
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseRemoteSessionInvalidUUID {
    // Arrange
    id mockUser = OCMClassMock([TTUser class]);
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([mockNotificationCenter postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSDictionary *userInfo = (NSDictionary *)obj;
        NSError *error = [userInfo objectForKey:kTTErrorUserInfoKey];
        return [error.domain isEqualToString:kTTSessionErrorDomain] && error.code == kTTSessionErrorParseSessionInvalidUUIDCode;
    }]]);
    OCMExpect([mockUserDefaults setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey]);
    
    // Parse local session VALID
    OCMStub([mockUser currentUser]).andReturn(mockUser);
    
    // Parse remote session INVALID (invalid UUID)
    OCMStub([mockUser activeDeviceIdentifier]).andReturn(@"fakeDeviceIdentifier");
    OCMStub([mockUser fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
        fetchInBackgroundBlock(mockUser, nil);
    });
    
    // Act
    [[TTSession sharedSession] validateSessionInBackground];
    
    // Assert
    OCMVerifyAll(mockNotificationCenter);
    OCMVerifyAll(mockUserDefaults);
}

- (void)testValidateSessionInBackgroundParseSessionValid {
    // Arrange
    id mockUser = OCMClassMock([TTUser class]);
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockNotificationCenter defaultCenter]).andReturn(mockNotificationCenter);
    OCMStub([mockUserDefaults standardUserDefaults]).andReturn(mockUserDefaults);
    OCMExpect([mockUserDefaults setBool:YES forKey:kTTParseSessionIsValidLastCheckedKey]);
    
    // Parse local session VALID
    OCMStub([mockUser currentUser]).andReturn(mockUser);
    
    // Parse remote session VALID
    OCMStub([mockUser activeDeviceIdentifier]).andReturn([UIDevice currentDevice].identifierForVendor.UUIDString);
    OCMStub([mockUser fetchInBackgroundWithBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^fetchInBackgroundBlock)(PFObject *object, NSError *error) = nil;
        [invocation getArgument:&fetchInBackgroundBlock atIndex:2];
        fetchInBackgroundBlock(mockUser, nil);
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
