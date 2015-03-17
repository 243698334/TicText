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
#import "TTTestHelper.h"
#import "TTUser.h"
#import "TTSession.h"

@interface TTUserTests : XCTestCase

@property (nonatomic, strong) id user;
@property (nonatomic, strong) id userPrivateData;

@end

@implementation TTUserTests

- (void)setUp {
    [super setUp];
    
    self.user = [[TTUser alloc] init];
    self.userPrivateData = [[TTUserPrivateData alloc] init];
}

- (void)testDisplayName {
    // Arrange
    NSString *displayName = @"foo";
    
    // Act
    [self.user setDisplayName:displayName];
    
    // Assert
    XCTAssertEqualObjects(displayName, [self.user displayName]);
}

- (void)testProfilePicture {
    // Arrange
    NSData *someData = UIImagePNGRepresentation([UIImage imageNamed:@"profile"]);
    
    // Act
    [self.user setProfilePicture:someData];
    
    // Assert
    XCTAssertEqualObjects(someData, [self.user profilePicture]);
}

- (void)testFriendsSetter {
    // Arrange
    NSArray *friends = @[@"foo", @"bar"];
    
    // Act
    [self.userPrivateData setFacebookFriends:friends];
    
    // Assert
    XCTAssertEqualObjects(friends, [self.userPrivateData facebookFriends]);

}

@end
