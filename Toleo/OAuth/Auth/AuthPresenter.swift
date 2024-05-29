import UIKit

protocol AuthPresenterProtocol: AnyObject {
    func signIn()
    func setup()
}

final class AuthPresenter {
    
    weak var view: AuthViewProtocol?
    private var authConfiguration: AuthConfiguration
    
    init(view: AuthViewProtocol, authConfiguration: AuthConfiguration) {
        self.view = view
        self.authConfiguration = authConfiguration
    }
    
    private func buildScreenModel() -> AuthScreenModel {
        .init(
            backgroundColor: UIColor.ypBlack,
            buttonTitle: "Войти",
            buttonColor: UIColor.ypWhite,
            logoImage: UIImage(named: "Vector") ?? UIImage(),
            font: .boldSystemFont(ofSize: 17)
        )
    }
    
    private func render() {
        view?.displayData(data: buildScreenModel())
    }
}

extension AuthPresenter: AuthPresenterProtocol {
    func signIn() {
        let webViewController = WebViewViewController()
        let authHelper = AuthHelper(configuration: authConfiguration)
        let webViewPresenter = WebViewPresenter(view: webViewController, authHelper: authHelper)
        
        webViewController.presenter = webViewPresenter
        webViewController.delegate = view as? WebViewControllerDelegate
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        view?.present(navigationController, animated: true)
    }
    
    func setup() {
        render()
    }
}

