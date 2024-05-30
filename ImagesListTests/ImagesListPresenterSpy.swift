import XCTest
@testable import Toleo

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var fetchPhotosNextPageCalled = false
    var addImageListObserverCalled = false
    
    func addImageListObserver() {
        addImageListObserverCalled = true
    }

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
}
