import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private var gradientLayer: CAGradientLayer?

    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = gradientView.bounds
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        configureGradientView()
        addGradient()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: URL(string: photo.smallImageURL), placeholder: UIImage(named: "Stub"))
        
        dateLabel.text = photo.createdAt?.toStringJustDate()
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    private func addGradient() {
        if gradientLayer == nil {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [#colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 0).cgColor, #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 0.2).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.locations = [0.0, 0.5]
            gradientView.layer.insertSublayer(gradientLayer, at: 0)
            self.gradientLayer = gradientLayer
        }
    }
    
    private func configureGradientView() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        cellImage.addSubview(gradientView)
        cellImage.bringSubviewToFront(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: cellImage.topAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor)
            
        ])
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
