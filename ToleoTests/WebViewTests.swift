import XCTest
@testable import Toleo

final class WebViewTests: XCTestCase {

    // Test loadWebView() call
    func testViewControllerCallsLoadWebView() {
        // Given
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.loadWebView()
        
        // Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    // Test updateProgress() call if progress < 1
    func testProgressVisibleWhenLessThenOne() {
        // Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: viewController, authHelper: authHelper)
        let progress: Float = 0.6
        
        // When
        presenter.updateProgress(progress: progress)
        
        // Then
        XCTAssertNotNil(viewController.lastProgressValue, "Progress update was not called")
        XCTAssertEqual(viewController.lastProgressValue, progress, "Progress should be visible and not reset to 0 when less than one")
    }
    
    // Test updateProgress() call if progress = 1
    func testProgressHiddenWhenOne() {
        // Given
        let viewSpy = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: viewSpy, authHelper: authHelper)
        let progress: Float = 1.0
        
        // When
        presenter.updateProgress(progress: progress)
        
        // Then
        XCTAssertNotNil(viewSpy.lastProgressValue, "Progress update was not called")
        XCTAssertEqual(viewSpy.lastProgressValue, 0, "Progress should be reset to 0 when equal to one, indicating it is hidden")
    }
    
    // Test .authURL() method
    func testAuthHelperAuthURL() {
        // Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        // When
        guard let url = authHelper.authURL() else {
            XCTFail("URL is nil")
            return
        }
        let urlString = url.absoluteString
        
        // Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test_code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        // When
        let code = authHelper.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test_code")
    }
}
