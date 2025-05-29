
import XCTest

final class APIHarborUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Flow Tests

    func testAppLaunch_ShowsAllAPIsTabFirst() throws {
        let allAPIsTabButton = app.tabBars.buttons["All APIs"]
        XCTAssertTrue(allAPIsTabButton.waitForExistence(timeout: 5), "All APIs tab button should exist")
        XCTAssertTrue(app.navigationBars["API Harbor"].waitForExistence(timeout: 5), "Navigation title for API Harbor list should be visible.")
    }

    func testTabNavigation_SwitchToFavoritesAndBack() throws {
        let allAPIsTabButton = app.tabBars.buttons["All APIs"]
        let favoritesTabButton = app.tabBars.buttons["Favorites"]

        XCTAssertTrue(allAPIsTabButton.waitForExistence(timeout: 5), "All APIs tab button should exist")
        XCTAssertTrue(favoritesTabButton.waitForExistence(timeout: 5), "Favorites tab button should exist")

        favoritesTabButton.tap()

        XCTAssertTrue(app.navigationBars["Favorite APIs"].waitForExistence(timeout: 5), "Navigation title for Favorites list should be visible.")

        allAPIsTabButton.tap()

        XCTAssertTrue(app.navigationBars["API Harbor"].waitForExistence(timeout: 5), "Navigation title for API Harbor list should be back.")
    }

    func testAPIList_DisplaysDataFromLocalJSON() throws {
        
        let catFactsRow = app.staticTexts["apiName_Cat Facts"]
        XCTAssertTrue(catFactsRow.waitForExistence(timeout: 10), "'Cat Facts' API entry should be visible.")

        let boredAPIRow = app.staticTexts["apiName_Bored API"]
        XCTAssertTrue(boredAPIRow.waitForExistence(timeout: 5), "'Bored API' entry should be visible.")
    }

    func testAPIList_SearchFunctionality() throws {
        let catFactsRow = app.staticTexts["apiName_Cat Facts"]
        XCTAssertTrue(catFactsRow.waitForExistence(timeout: 10), "'Cat Facts' API entry should be visible.")

        let searchField = app.navigationBars.element.searchFields.firstMatch
        
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")
        searchField.tap()
        searchField.typeText("Cat")

        XCTAssertTrue(app.staticTexts["apiName_Cat Facts"].exists)
        XCTAssertFalse(app.staticTexts["apiName_Bored API"].exists, "'Bored API' should be filtered out.")

        if searchField.buttons["Clear text"].exists {
            searchField.buttons["Clear text"].tap()
        } else {
            let currentSearchText = searchField.value as? String ?? ""
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentSearchText.count))
        }
        
        XCTAssertTrue(app.staticTexts["apiName_Bored API"].waitForExistence(timeout: 5), "'Bored API' should reappear after clearing search.")
    }

    func testFavoritingFlow() throws {

        let catFactsAPIName = "Cat Facts"
        let catFactsRowText = app.staticTexts["apiName_\(catFactsAPIName)"]
        let catFactsFavoriteButton = app.buttons["favoriteButton_\(catFactsAPIName)"]

        XCTAssertTrue(catFactsRowText.waitForExistence(timeout: 10), "'\(catFactsAPIName)' row should exist.")
        XCTAssertTrue(catFactsFavoriteButton.waitForExistence(timeout: 5), "Favorite button for '\(catFactsAPIName)' should exist.")

        catFactsFavoriteButton.tap()
        sleep(1)

        let favoritesTabButton = app.tabBars.buttons["Favorites"]
        favoritesTabButton.tap()

        let favoriteCatFactsRowText = app.collectionViews["favoritesAPIsList"].staticTexts["apiName_\(catFactsAPIName)"]
        XCTAssertTrue(favoriteCatFactsRowText.waitForExistence(timeout: 5), "'\(catFactsAPIName)' should now be in the Favorites list.")

        let favoriteCatFactsFavoriteButtonInFavorites = app.collectionViews["favoritesAPIsList"].buttons["favoriteButton_\(catFactsAPIName)"]
        XCTAssertTrue(favoriteCatFactsFavoriteButtonInFavorites.waitForExistence(timeout:5), "Favorite button for Cat Facts in Favorites list should exist")
        favoriteCatFactsFavoriteButtonInFavorites.tap()
        sleep(1)

        XCTAssertFalse(favoriteCatFactsRowText.exists, "'\(catFactsAPIName)' should be removed from Favorites list after unfavoriting.")
        
        let allAPIsTabButton = app.tabBars.buttons["All APIs"]
        allAPIsTabButton.tap()
        
        XCTAssertTrue(catFactsFavoriteButton.waitForExistence(timeout: 5), "Favorite button for Cat Facts should exist on All APIs list.")
    }
}
