//
//  TTUserTests.m
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
#import "TTUser.h"

@interface TTUserTests : XCTestCase

@property (nonatomic, strong) id mockPFUser;
@property (nonatomic, strong) TTUser *user;

@end

@implementation TTUserTests

- (void)setUp {
    [super setUp];

    self.mockPFUser = OCMClassMock([PFUser class]);
    self.user = [TTUser wrap:self.mockPFUser];
}

- (void)testPFUserInit {
    // Arrange
    PFUser *fakeUser = [TTHelper fakeUser];
    
    // Act
    self.user = [TTUser wrap:fakeUser];
    
    // Assert
    XCTAssertEqualObjects(fakeUser, self.user.pfUser);
}

- (void)testDisplayNameSetter {
    // Arrange
    NSString *displayName = @"foo";
    OCMExpect([self.mockPFUser setObject:displayName forKey:kTTUserDisplayNameKey]);
    
    // Act
    [self.user setDisplayName:displayName];
    
    // Assert
    OCMVerifyAll(self.mockPFUser);
}

- (void)testDisplayNameGetter {
    // Arrange
    NSString *displayName = @"foo";
    
    // Act
    [self.user setDisplayName:displayName];
    
    // Assert
    XCTAssertEqualObjects(displayName, self.user.displayName);
}

- (void)testProfilePictureSetter {
    // Arrange
    NSData *someData = [NSData data];
    OCMExpect([self.mockPFUser setObject:[OCMArg isNotNil] forKey:kTTUserProfilePictureKey]);
    
    // Act
    [self.user setProfilePicture:someData];
    
    // Assert
    OCMVerifyAll(self.mockPFUser);
}

- (void)testProfilePictureGetter {
    // Arrange
    NSData *someData = [NSData data];
    
    // Act
    [self.user setProfilePicture:someData];
    
    // Assert
    XCTAssertEqualObjects(someData, self.user.profilePicture);
}

- (void)testFriendsSetter {
    // Arrange
    NSArray *friends = @[@"foo", @"bar"];
    OCMExpect([self.mockPFUser setObject:friends forKey:kTTUserTicTextFriendsKey]);
    
    // Act
    [self.user setFriends:friends];
    
    // Assert
    OCMVerifyAll(self.mockPFUser);
}

- (void)testFriendsGetter {
    // Arrange
    NSArray *friends = @[@"foo", @"bar"];
    
    // Act
    [self.user setFriends:friends];
    
    // Assert
    XCTAssertEqualObjects(friends, self.user.friends);
}

@end
