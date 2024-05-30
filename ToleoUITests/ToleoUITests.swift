import XCTest

extension XCUIElement {
    func enterTextWithDelay(_ text: String) {
        for char in text {
            self.typeText(String(char))
            usleep(100_000)
        }
    }
}

final class ToleoUITests: XCTestCase {
    private let email: String = "postoyanstvo@yahoo.com"
    private let password: String = "kUsn8pwVvcR!5QV"
    private let fullName: String = "Konstantin Bukin"
    private let username: String = "@postoyanstvo"
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        
        sleep(5)
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(email)
        app.buttons["Done"].tap()
        sleep(2)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(password)
        //passwordTextField.enterTextWithDelay(password)
        
        app.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        sleep(2)
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        sleep(3)
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(3)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["LikeButton"].tap()
        
        sleep(3)
        
        cellToLike.buttons["LikeButton"].tap()
        
        sleep(3)
        
        cellToLike.tap()
        
        sleep(10)
            
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Back"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(5)
       
        XCTAssertTrue(app.staticTexts[fullName].exists)
        XCTAssertTrue(app.staticTexts[username].exists)
        
        app.buttons["Exit"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
