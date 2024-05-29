import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "LikeButton"
        
        return button
    }()
    private var gradientLayer: CAGradientLayer?
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        
        return imageView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.ypWhite
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = gradientView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(cellImage)
        containerView.addSubview(gradientView)
        containerView.addSubview(likeButton)
        cellImage.addSubview(dateLabel)
        
        setupContainerView()
        setupImage()
        setupGradientView()
        setupLabel()
        setupLikeButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    private func setupGradientView() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        cellImage.addSubview(gradientView)
        cellImage.bringSubviewToFront(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: cellImage.topAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor)
            
        ])
        addGradient()
    }
    
    private func setupImage() {
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.imageInsets),
            cellImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.leadingTrailingInsets),
            cellImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.leadingTrailingInsets),
            cellImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.imageInsets),
        ])
    }
    
    private func setupLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: Constants.insets),
            dateLabel.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -Constants.insets),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -Constants.insets),
            dateLabel.widthAnchor.constraint(equalToConstant: Constants.labelWidth)
        ])
    }
    
    private func setupLikeButton() {
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidthHeight),
            likeButton.heightAnchor.constraint(equalToConstant: Constants.buttonWidthHeight)
        ])
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        containerView.backgroundColor = .clear
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
    
    private enum Constants {
        static let insets: CGFloat = 8
        static let labelWidth: CGFloat = 18
        static let buttonWidthHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 16
        static let imageInsets: CGFloat = 4
        static let leadingTrailingInsets: CGFloat = 16
    }
}
