import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        //tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier) если таблица настраивается с помощью кода
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru")
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count //сколько ячеек в секции
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
        
        cell.cellImage.image = image
        cell.likeButton.setImage(UIImage(named: "No Active"), for: .normal)
        cell.likeButton.setImage(UIImage(named: "Active"), for: .selected)
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.isSelected = true
        } else {
            cell.likeButton.isSelected = false
        }
                
        setBackgroundGradient(for: cell, with: indexPath)
    }
    
    func setBackgroundGradient(for cell: ImagesListCell, with indexPath: IndexPath) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.gradient.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 0).cgColor, #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 0.2).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.locations = [0.0, 0.5]

        cell.gradient.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //действия при тапе на ячейку
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

