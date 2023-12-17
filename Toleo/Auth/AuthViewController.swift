import UIKit

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for\(ShowWebViewSegueIdentifier)") }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
