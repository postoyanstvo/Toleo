import UIKit

final class OAuthViewController: UIViewController {    
    private enum Constants {
        static let sighInButtonHeight: CGFloat = 48
        static let insets: CGFloat = 16
        static let bottomInsets: CGFloat = 90
        static let logoSize: CGFloat = 60
        static let cornerRadius: CGFloat = 16
    }

    weak var delegate: OAuthViewControllerDelegate?
    var presenter: AuthPresenter?
    
    private var logoImageView = UIImageView()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.accessibilityIdentifier = "Authenticate"
        return button
    }()
    
    private var screenModel: AuthScreenModel = .empty {
        didSet { setup() }
    }
    
    init(delegate: OAuthViewControllerDelegate, authConfiguration: AuthConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.presenter = AuthPresenter(view: self, authConfiguration: authConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.setup()
        configureView()
    }
    
    private func setup() {
        view.backgroundColor = screenModel.backgroundColor
        logoImageView.image = screenModel.logoImage
        configureSignInButton()
    }
    
    private func configureView() {
        configureSubviews()
        configureConstraints()
    }
    
    private func configureSignInButton() {
        signInButton.setTitle(screenModel.buttonTitle, for: .normal)
        signInButton.backgroundColor = screenModel.buttonColor
        signInButton.setTitleColor(screenModel.backgroundColor, for: .normal)
        signInButton.titleLabel?.font = screenModel.font
        signInButton.addTarget(self, action: #selector(signInButtonClicked), for: .touchUpInside)
    }
    
    @objc private func signInButtonClicked() {
        presenter?.signIn()
    }
    
    private func configureConstraints() {
        setupSignInButtonConstraints()
        setupLogoConstraints()
    }
    
    private func configureSubviews() {
        view.addSubview(signInButton)
        view.addSubview(logoImageView)
    }
    
    private func setupSignInButtonConstraints() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.heightAnchor.constraint(equalToConstant: Constants.sighInButtonHeight),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.insets),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.insets),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomInsets)
        ])
    }
    
    private func setupLogoConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: Constants.logoSize),
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.logoSize)
        ])
    }
}

extension OAuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

protocol OAuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: OAuthViewController, didAuthenticateWithCode code: String)
}

protocol AuthViewProtocol: UIViewController {
    func displayData(data: AuthScreenModel)
    var delegate: OAuthViewControllerDelegate? { get }
}

extension OAuthViewController: AuthViewProtocol {
    func displayData(data: AuthScreenModel) {
        self.screenModel = data
    }
}
