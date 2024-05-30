import XCTest
@testable import Toleo

final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled = false

    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}
