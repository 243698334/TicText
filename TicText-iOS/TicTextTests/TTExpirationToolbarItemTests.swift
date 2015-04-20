//
//  TTExpirationToolbarItemTests.swift
//  TicText
//
//  Created by Terrence K on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

class TTExpirationToolbarItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWidthMultiplier() {
        // @stub
    }
    
    func testContentView() {
        // @stub
    }
    
    func testButtonOnSelect() {
        // @stub
    }
    
    func testButtonOnDeselect() {
        // @stub
    }
    
    func testSwitchViewOnAction() {
        // @stub
    }
    
    /*
    - (void)testDidPressAccessoryButton {
        // Pre-condition
        XCTAssert([self.mockMessagesViewController pickerController] == nil);

        // Act
        [self.mockMessagesViewController didPressAccessoryButton:nil];

        // Assert
        XCTAssert([self.mockMessagesViewController pickerController] != nil);
        XCTAssert([[self.mockMessagesViewController pickerController] superview] != nil);
    }

    - (void)testPickerControllerDidFinishWithExpirationZeroValue {
        // Arrange
        TTExpirationPickerController *controller = [[TTExpirationPickerController alloc] init];
        [self.mockMessagesViewController setPickerController:controller];
        [self.mockMessagesViewController setExpirationTime:3600];
        OCMExpect([self.mockMessagesViewController refreshExpirationToolbar:0]);

        // Act
        [self.mockMessagesViewController pickerController:controller didFinishWithExpiration:0];

        // Assert
        OCMVerifyAll(self.mockMessagesViewController);
    }

    - (void)testPickerControllerDidFinishWithExpirationSomeValue {
        // Arrange
        TTExpirationPickerController *controller = [[TTExpirationPickerController alloc] init];
        [self.mockMessagesViewController setPickerController:controller];
        [self.mockMessagesViewController setExpirationTime:3600];
        OCMExpect([self.mockMessagesViewController refreshExpirationToolbar:1337]);

        // Act
        [self.mockMessagesViewController pickerController:controller didFinishWithExpiration:1337];

        // Assert
        OCMVerifyAll(self.mockMessagesViewController);
    }
*/

}
