import XCTest

final class ImFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 1))
        
        loginTextField.tap()
        loginTextField.typeText("your_email")
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 1))
        
        passwordTextField.tap()
        passwordTextField.typeText("your_password")
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        firstCell.swipeUp()
        
        
        let cellToLike = app.tables.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Вторая ячейка не найдена.")
        
        let likeButton = cellToLike.buttons["LikeButton"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка не найдена.")
        
        likeButton.tap()
        sleep(2)
        
        cellToLike.tap()
        
        let image = app.scrollViews.images["SingleImage"]
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButton = app.buttons["BackButton"]
        XCTAssertTrue(navBackButton.exists, "Кнопка возврата не найдена.")
        navBackButton.tap()
        
        XCTAssertTrue(firstCell.exists, "Не удалось вернуться к списку изображений.")
    }
    
    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Konstantin Bukin"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["@postoyanstvo"].waitForExistence(timeout: 5))
        
        app.buttons["logoutButton"].tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Да"].tap()
    }
}
