import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru")
        
        return formatter
    }()
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        addImageListObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func addImageListObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    private func configureCell(_ cell: ImagesListCell, for indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.configure(with: photo, dateFormatter: dateFormatter)
        cell.delegate = self
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        configureCell(cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageHeight = photo.size.height
        let imageWidth = photo.size.width
        
        let tableViewWidth = tableView.bounds.width
        let scale = tableViewWidth / imageWidth
        
        return imageHeight * scale
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImageViewController(with: photos[indexPath.row])
    }
    
    private func showSingleImageViewController(with photo: Photo) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.photo = photo
        let navigationController = UINavigationController(rootViewController: singleImageVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = imagesListService.photos.count - 1
        if indexPath.row == lastElement {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let isLike = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            switch result {
            case .success():
                self?.photos[indexPath.row].isLiked = isLike
                self?.tableView.reloadRows(at: [indexPath], with: .none)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("Error changing like status: \(error)")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
