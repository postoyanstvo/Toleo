import UIKit

final class ImagesListViewController: UIViewController {
    private var showSingleImageIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView?
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named:photosName[indexPath.row]) else {
            return
        }
        let gradientLayer = setBackgroundGradient(for: cell, with: indexPath)
        
        cell.confugure(cellImage: image,
                       noActiveButtonImage: UIImage(named: "No Active") ?? UIImage(),
                       activeButtonImage: UIImage(named: "Active") ?? UIImage(),
                       date: dateFormatter.string(from: Date()),
                       isSelected: indexPath.row % 2 == 0,
                       gradientLayer: gradientLayer
        )
    }
    
    func setBackgroundGradient(for cell: ImagesListCell, with indexPath: IndexPath) -> CAGradientLayer{
        let gradientLayer = CAGradientLayer()
        guard let gradientBounds = cell.getGradientBounds() else {
            return CAGradientLayer()
        }
        gradientLayer.frame = gradientBounds
        gradientLayer.colors = [#colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 0).cgColor, #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 0.2).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.locations = [0.0, 0.5]

        return gradientLayer
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named:photosName[indexPath.row]) else {
            return 0
        }
        let imageInserts = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWight = tableView.bounds.width - imageInserts.left - imageInserts.right
        let imageWight = image.size.width
        let scale = imageViewWight/imageWight
        let imageHeight = image.size.height
        let cellHeight = imageHeight * scale - imageInserts.top - imageInserts.bottom
        return cellHeight
    }
}

