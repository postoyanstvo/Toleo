import UIKit

struct AlertService {
    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        viewController.present(alert, animated: true)
    }
}
