//
//  FrogGuardUITests.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 2.6.2025.
//


import XCTest

final class FrogGuardUITests: XCTestCase {

    func testMapGridToggleButtonIsAccessible() throws {
        let app = XCUIApplication()
        app.launch()

        // Find the button by its accessibility label
        let toggleButton = app.buttons["Toggle between map and grid view"]

        // Check that it exists and is hittable
        XCTAssertTrue(toggleButton.exists, "Toggle button should exist on screen.")
        XCTAssertTrue(toggleButton.isHittable, "Toggle button should be tappable.")

        // Optional: tap it
        toggleButton.tap()
    }
}
