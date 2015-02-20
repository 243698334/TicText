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

#import <Parse/Parse.h>
#import "TTHelper.h"
#import "TTSession.h"

@interface TTSessionTests : XCTestCase

@property (nonatomic, strong) id mockPFUser;
@property (nonatomic, strong) PFUser *fakeUser;

@end

@implementation TTSessionTests

- (void)setUp {
    [super setUp];
    
    self.mockPFUser = OCMClassMock([PFUser class]);
    self.fakeUser = [TTHelper fakeUser];
    
}

- (void)testCurrentUserNil {
    // Arrange
    OCMStub([self.mockPFUser currentUser]).andReturn(nil);
    
    // Act
    TTUser *retUser = [[TTSession sharedSession] currentUser];
    
    // Assert
    XCTAssertNil(retUser);
}

- (void)testCurrentUser {
    // Arrange
    OCMStub([self.mockPFUser currentUser]).andReturn(self.fakeUser);
    
    // Act
    TTUser *retUser = [[TTSession sharedSession] currentUser];
    
    // Assert
    XCTAssertNotNil(retUser);
    XCTAssertTrue([retUser isKindOfClass:[TTUser class]]);
    
    XCTAssertEqualObjects(self.fakeUser[kTTUserDisplayNameKey], retUser.displayName);
    XCTAssertEqualObjects(self.fakeUser[kTTUserProfilePictureKey], retUser.profilePicture);
    XCTAssertEqualObjects(self.fakeUser[kTTUserTicTextFriendsKey], retUser.friends);
}

- (void)testIsUserLoggedInTrue {
    XCTAssertTrue(NO); // @stub
}

- (void)testIsUserLoggedInFalse {
    XCTAssertTrue(NO); // @stub
}

- (void)testFacebookLoginSuccess {
    XCTAssertTrue(NO); // @stub
}

- (void)testFacebookLoginFailure {
    XCTAssertTrue(NO); // @stub
}

- (void)testFacebookLogoutSuccess {
    XCTAssertTrue(NO); // @stub
}

- (void)testFacebookLogoutFailure {
    XCTAssertTrue(NO); // @stub
}

- (void)testSyncFriendsSuccess {
    XCTAssertTrue(NO); // @stub
}

- (void)testSyncFriendsFailure {
    XCTAssertTrue(NO); // @stub
}

- (void)testSyncProfilePictureSuccess {
    XCTAssertTrue(NO); // @stub
}

- (void)testSyncProfilePictureFailure {
    XCTAssertTrue(NO); // @stub
}

- (void)testSyncUserDataSuccess {
    XCTAssertTrue(NO); // @stub
}

- (void)testSyncUserDataFailure {
    XCTAssertTrue(NO); // @stub
}

@end
