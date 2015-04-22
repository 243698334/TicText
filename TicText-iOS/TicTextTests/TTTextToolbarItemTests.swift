//
//  TTTextToolbarItemTests.swift
//  TicText
//
//  Created by Terrence K on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

class TTTextToolbarItemTests: XCTestCase {

    var toolbarItem: TTTextToolbarItem!
    
    override func setUp() {
        super.setUp()
        
        toolbarItem = TTTextToolbarItem()
    }
    
    func testItemTitle() {
        XCTAssertEqual(toolbarItem.titleLabel!.text!, "Aa")
    }
    
    func testWidthMultiplier() {
        XCTAssertEqual(toolbarItem.widthMultiplier(), 1.0)
    }
    
    func testContentView() {
        XCTAssertNil(toolbarItem.contentView)
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
        XCTAssertEqual(toolbarItem.className, "TTTextToolbarItem")
    }
    
}
