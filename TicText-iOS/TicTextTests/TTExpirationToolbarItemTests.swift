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

    class ToolbarDelegate: NSObject, TTMessagesToolbarDelegate {
        
        var expirationTime: NSTimeInterval = 0
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, setAnonymousTic anonymous: Bool) { }
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, setExpirationTime expirationTime: NSTimeInterval) {
            self.expirationTime = expirationTime
        }
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, willHideItem item: TTMessagesToolbarItem!) { }
        
        @objc func messagesToolbar(toolbar: TTMessagesToolbar!, willShowItem item: TTMessagesToolbarItem!) { }
        
        @objc func currentExpirationTime() -> NSTimeInterval {
            return self.expirationTime
        }
    }
    
    var toolbarItem: TTExpirationToolbarItem!
    var toolbar: TTMessagesToolbar!
    var toolbarDelegate: ToolbarDelegate!
    
    override func setUp() {
        super.setUp()
        
        self.toolbarItem = TTExpirationToolbarItem()
        self.toolbar = TTMessagesToolbar()
        self.toolbarDelegate = ToolbarDelegate()
        toolbar.delegate = toolbarDelegate
        toolbarItem.toolbar = toolbar
    }
    
    func testInitWithFrame() {
        XCTAssertEqual(toolbarItem.titleLabel!.numberOfLines, 2)
        XCTAssertEqual(toolbarItem.contentHorizontalAlignment, .Left)
    }
    
    func testWidthMultiplier() {
        XCTAssertEqual(toolbarItem.widthMultiplier(), 3.0)
    }
    
    func testContentView() {
        XCTAssertNil(toolbarItem.contentView)
    }
    
    func testButtonOnSelect() {
        XCTAssertEqual(toolbarItem.selected, false, "invariant")
        
        XCTAssertEqual(toolbarItem.toolbar, toolbar)
        XCTAssertEqual(toolbarItem.titleLabel!.text!, "Expires\ninstantly")
        XCTAssertNil(toolbarItem.pickerController)
        
        // Act
        toolbarItem.buttonOnSelect(toolbar)
        
        // Assert
        XCTAssertNotNil(toolbarItem.pickerController)
        XCTAssertEqual(toolbarItem.selected, false, "invariant")
        
        // Cleanup
        toolbarItem.pickerController.dismiss()
    }
    
    func testSwitchViewOnAction() {
        XCTAssertEqual(toolbarItem.shouldSwitchViewOnAction(), false)
    }
    
    func testToolbarItemClassName() {
        XCTAssertEqual(toolbarItem.className, "TTExpirationToolbarItem")
    }
    
    // MARK: TTExpirationPickerControllerDelegate
    func testPickerControllerDidFinishWithExpiration() {
        // Arrange
        let controller = TTExpirationPickerController()
        toolbarItem.pickerController = controller
        
        // Act
        toolbarItem.pickerController(controller, didFinishWithExpiration: 42)
        
        // Assert
        XCTAssertEqual(toolbarItem.titleLabel!.text!, "Expires in\n42s")
        XCTAssertEqual(toolbarDelegate.expirationTime, 42)
    }
    
    func testPickerControllerDidFinishWithExpiration2() {
        // Arrange
        let controller = TTExpirationPickerController()
        toolbarItem.pickerController = controller
        
        // Act
        toolbarItem.pickerController(controller, didFinishWithExpiration: 3666)
        
        // Assert
        XCTAssertEqual(toolbarItem.titleLabel!.text!, "Expires in\n1h 1m 6s")
        XCTAssertEqual(toolbarDelegate.expirationTime, 3666)
    }

}
