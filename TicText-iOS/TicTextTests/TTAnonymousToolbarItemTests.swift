//
//  TTAnonymousToolbarItemTests.swift
//  TicText
//
//  Created by Terrence K on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import XCTest

class TTAnonymousToolbarItemTests: XCTestCase {
    
    class ToolbarDelegate: NSObject, TTMessagesToolbarDelegate {
        
        var isAnonymous = false
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, setAnonymousTic anonymous: Bool) {
            self.isAnonymous = anonymous
        }
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, setExpirationTime expirationTime: NSTimeInterval) { }
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, willHideItem item: TTMessagesToolbarItem!) { }
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, willShowItem item: TTMessagesToolbarItem!) { }
        
        @objc func expirationTime() -> NSTimeInterval {
            return 0
        }
    }

    var toolbarItem: TTAnonymousToolbarItem!
    
    override func setUp() {
        super.setUp()
        
        toolbarItem = TTAnonymousToolbarItem()
    }
    
    func testItemTitle() {
        XCTAssertEqual(toolbarItem.titleLabel!.text!, "Anonymous")
    }
    
    func testWidthMultiplier() {
        XCTAssertEqual(toolbarItem.widthMultiplier(), 2.0)
    }
    
    func testContentView() {
        XCTAssertNil(toolbarItem.contentView)
    }
    
    func testButtonOnSelect() {
        // Arrange
        toolbarItem.selected = false
        
        let toolbar = TTMessagesToolbar()
        let toolbarDelegate = ToolbarDelegate()
        toolbar.delegate = toolbarDelegate
        toolbarItem.toolbar = toolbar
        
        XCTAssertEqual(toolbarItem.selected, false, "precondition")
        XCTAssertNotNil(toolbarItem.toolbar, "precondition")
        
        // Act
        toolbarItem.didSelectToolbarButton(toolbar)
        
        // Assert
        XCTAssertEqual(toolbarItem.selected, true)
        XCTAssertEqual(toolbarDelegate.isAnonymous, true)
    }
    
    func testButtonOnSelect2() {
        // Arrange
        toolbarItem.selected = true
        
        let toolbar = TTMessagesToolbar()
        let toolbarDelegate = ToolbarDelegate()
        toolbarDelegate.isAnonymous = true
        toolbar.delegate = toolbarDelegate
        toolbarItem.toolbar = toolbar
        
        XCTAssertEqual(toolbarItem.selected, true, "precondition")
        XCTAssertNotNil(toolbarItem.toolbar, "precondition")
        
        // Act
        toolbarItem.didSelectToolbarButton(toolbar)
        
        // Assert
        XCTAssertEqual(toolbarItem.selected, false)
        XCTAssertEqual(toolbarDelegate.isAnonymous, false)
    }
    
    func testSwitchViewOnAction() {
        XCTAssertEqual(toolbarItem.shouldSwitchViewOnAction(), false)
    }
    
    func testToolbarItemClassName() {
        XCTAssertEqual(toolbarItem.className, "TTAnonymousToolbarItem")
    }

}
