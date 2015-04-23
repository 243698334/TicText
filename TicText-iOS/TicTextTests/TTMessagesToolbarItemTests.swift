//
//  TTMessagesToolbarItemTests.swift
//  TicText
//
//  Created by Terrence K on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

// These tests are mostly specification tests - just update these tests when you are intentionally changing the code under test.
class TTMessagesToolbarItemTests: XCTestCase {

    var toolbarItem: TTMessagesToolbarItem!
    
    override func setUp() {
        super.setUp()
        
        toolbarItem = TTMessagesToolbarItem()
    }

    func testWidthMultiplier() {
        XCTAssertEqual(toolbarItem.widthMultiplier(), 1.0)
    }
    
    func testContentView() {
        let view = toolbarItem.contentView
        XCTAssertNotNil(view)
        XCTAssert(view.isKindOfClass(UIView.self))
    }
    
    func testButtonOnSelect() {
        // Arrange
        toolbarItem.selected = false
        
        XCTAssertEqual(toolbarItem.selected, false, "precondition")
        XCTAssertNil(toolbarItem.toolbar, "precondition")
        
        // Act
        toolbarItem.didSelectToolbarButton(nil)
        
        // Assert
        XCTAssertEqual(toolbarItem.selected, true)
    }
    
    func testButtonOnDeselect() {
        // Arrange
        toolbarItem.selected = true
        
        XCTAssertEqual(toolbarItem.selected, true, "precondition")
        XCTAssertNil(toolbarItem.toolbar, "precondition")
        
        // Act
        toolbarItem.didDeselectToolbarButton(nil)
        
        // Assert
        XCTAssertEqual(toolbarItem.selected, false)
    }
    
    func testSwitchViewOnAction() {
        XCTAssertEqual(toolbarItem.shouldSwitchViewOnAction(), true)
    }
    
    func testToolbarItemClassName() {
        XCTAssertEqual(toolbarItem.className, "TTMessagesToolbarItem")
    }

}
