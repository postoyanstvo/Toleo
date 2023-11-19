import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBAction private func didTapLogoutButton() {
    }
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
}
