import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet private weak var cellImage: UIImageView?
    @IBOutlet private weak var likeButton: UIButton?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var labelGradient: UIView?
    
    func confugure(cellImage: UIImage,
                   noActiveButtonImage: UIImage,
                   activeButtonImage: UIImage,
                   date: String,
                   isSelected: Bool,
                   gradientLayer: CAGradientLayer) {
        self.cellImage?.image = cellImage
        self.likeButton?.setImage(noActiveButtonImage, for: .normal)
        self.likeButton?.setImage(activeButtonImage, for: .selected)
        self.dateLabel?.text = date
        self.likeButton?.isSelected = isSelected
        self.labelGradient?.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func getGradientBounds() -> CGRect? {
        return self.labelGradient?.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelGradient?.layer.sublayers = nil
    }
}
