//
//  TTMessagesToolbarTests.swift
//  TicText
//
//  Created by Terrence K on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

// Helper class
class VariableWidthToolbarItem: TTMessagesToolbarItem {
    
    var _widthMultiplier: CGFloat = 0
    
    init(multiplier: CGFloat) {
        super.init(frame: CGRectZero)
        _widthMultiplier = multiplier
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func widthMultiplier() -> CGFloat {
        return _widthMultiplier
    }
}

// These tests are mostly specification tests - just update these tests when you are intentionally changing the code under test.
class TTMessagesToolbarTests: XCTestCase {
    
    var toolbar: TTMessagesToolbar!
    override func setUp() {
        let someFrame = CGRect(x: 0, y: 0, width: 320.0, height: 64.0)
        toolbar = TTMessagesToolbar(frame: someFrame)
    }
    
    func testInitWithFrameToolbarItems() {
        let someFrame = CGRect(x: 1.0, y: 2.0, width: 3.0, height: 4.0)
        let someItems = [TTMessagesToolbarItem(), TTMessagesToolbarItem()]
        
        let toolbar = TTMessagesToolbar(frame: someFrame, toolbarItems: someItems)
        
        XCTAssertEqual(toolbar.frame, someFrame, "frame")
        XCTAssertEqual(toolbar.backgroundColor!, UIColor.whiteColor(), "backgroundColor")
        XCTAssertEqual(toolbar.toolbarItems as! [TTMessagesToolbarItem], someItems, "toolbarItems")
        XCTAssertEqual(toolbar.selectedIndex, -1, "selectedIndex")
        XCTAssertNotNil(toolbar.topBorder, "topBorder")
    }
    
    func testInitWithFrame() {
        let toolbar = TTMessagesToolbar(frame: CGRectZero)
        
        XCTAssertGreaterThanOrEqual(toolbar.toolbarItems.count, 1, "toolbarItems")
        
        let firstItem: TTMessagesToolbarItem = toolbar.toolbarItems[0] as! TTMessagesToolbarItem
        
        XCTAssertEqual(firstItem.className, "TTTextToolbarItem", "class name")
    }
    
    func testTopBorderFrame() {
        let frame = toolbar.topBorderFrame()
        XCTAssertEqual(frame.origin.x, 0, "origin.x")
        XCTAssertEqual(frame.origin.y, 0, "origin.y")
        XCTAssertEqual(frame.size.width, 320, "size.width")
        XCTAssertEqual(frame.size.height, 1, "size.height")
    }
    
    func testSetupTopBorder() {
        // Arrange
        toolbar.topBorder = nil
        
        // Act
        toolbar.setupTopBorder()
        
        // Assert
        XCTAssertNotNil(toolbar.topBorder, "topBorder")
        XCTAssertNotEqual(toolbar.topBorder.backgroundColor!, UIColor.clearColor(), "topBorder.backgroundColor")
        XCTAssertNotNil(toolbar.topBorder.superview, "topBorder.superview")
    }
    
    func testSetupButtons() {
        // Arrange
        for view in toolbar.subviews as! [UIView] {
            view.removeFromSuperview()
        }
        
        // Act
        toolbar.setupButtons()
        
        // Assert
        XCTAssertEqual(toolbar.toolbarItems.count, toolbar.subviews.count, "mismatch")
        for view in toolbar.subviews as! [UIView] {
            XCTAssertTrue(contains(toolbar.toolbarItems as! [UIView], view))
        }
        for view in toolbar.toolbarItems as! [UIView] {
            XCTAssertTrue(contains(toolbar.subviews as! [UIView], view))
        }
    }

    func testToggleFirstItem() {
        XCTAssertEqual(toolbar.selectedIndex, -1, "pre-condition")
        
        // Arrange
        let firstItem = toolbar.toolbarItems.first as! TTMessagesToolbarItem
        
        // Act
        toolbar.toggleItem(firstItem)
        
        // Assert
        XCTAssertEqual(toolbar.selectedIndex, 0, "post-condition")
    }
    
    func testToggleNoSwitchItem() {
        testToggleFirstItem()
        
        XCTAssertEqual(toolbar.selectedIndex, 0, "pre-condition")
        
        // Arrange
        var noSwitchItem: TTMessagesToolbarItem!
        for item in toolbar.toolbarItems as! [TTMessagesToolbarItem] {
            if item.shouldSwitchViewOnAction() == false {
                noSwitchItem = item
                break
            }
        }
        
        XCTAssertNotNil(noSwitchItem, "unable to acquire a no-switch item")
        
        // Act
        toolbar.toggleItem(noSwitchItem)
        
        // Assert
        XCTAssertEqual(toolbar.selectedIndex, 0, "post-condition")
    }
    
    func testFrameForButtonIndex() {
        // Arrange
        let firstItem = VariableWidthToolbarItem(multiplier: 3)
        let secondItem = VariableWidthToolbarItem(multiplier: 1)
        let thirdItem = VariableWidthToolbarItem(multiplier: 4)
        
        let toolbar = TTMessagesToolbar(frame: self.toolbar.frame, toolbarItems: [firstItem, secondItem, thirdItem])
        
        // Act
        let firstFrame = toolbar.frameForButtonIndex(0)
        let secondFrame = toolbar.frameForButtonIndex(1)
        let thirdFrame = toolbar.frameForButtonIndex(2)
        
        // Arrange Expected
        let expectedItemWidth = toolbar.frame.size.height
        let expectedItemHeight = expectedItemWidth
        
        let expectedFirstFrame = CGRect(x: 0, y: 0, width: expectedItemWidth * 3, height: expectedItemHeight)
        let expectedSecondFrame = CGRect(x: expectedItemWidth * 3, y: 0, width: expectedItemWidth * 1, height: expectedItemHeight)
        let expectedThirdFrame = CGRect(x: expectedItemWidth * 4, y: 0, width: expectedItemWidth * 4, height: expectedItemHeight)
        
        // Assert
        XCTAssertEqual(firstFrame, expectedFirstFrame, "")
        XCTAssertEqual(secondFrame, expectedSecondFrame, "")
        XCTAssertEqual(thirdFrame, expectedThirdFrame, "")
    }

}
