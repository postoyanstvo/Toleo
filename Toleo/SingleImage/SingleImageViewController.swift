import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var photo: Photo?
    private let scrollView = UIScrollView()
    private let imageView: UIImageView = {
        let photoView = UIImageView()
        photoView.contentMode = .scaleAspectFill
        
        return photoView
    }()
    private let sharedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Share"), for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        [scrollView,
         imageView,
         sharedButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
             view.addSubview($0)
        }
        view.backgroundColor = .ypBlack
        sharedButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        setImageZoomScale()
        setupSharingButton()
        setupNavigationBar()
        setupScrollView()
        setSingleImage()
        setupImage()
    }
    
    @objc private func shareButtonTapped() {
        guard let image = imageView.image else { return }
        let items = [image]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        backItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
        UIBlockingProgressHUD.dismiss()
    }
    
    private func setupImage() {
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
    }
    
    private func setupScrollView() {
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateScrollViewContentSize() {
        scrollView.contentSize = imageView.frame.size
    }
    
    private func setupSharingButton() {
        
        NSLayoutConstraint.activate([
            sharedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sharedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            sharedButton.widthAnchor.constraint(equalToConstant: .shareButtonSize),
            sharedButton.heightAnchor.constraint(equalToConstant: .shareButtonSize)
        ])
    }
    
    private func setImageZoomScale() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = imageView.frame.size
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.setSingleImage()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setSingleImage() {
        guard let photo = photo,
              let lowResURL = URL(string: photo.smallImageURL),
              let highResURL = URL(string: photo.thumbImageURL) else { return }
        
        UIBlockingProgressHUD.showAndEnableUserInteraction()
        
        // Download the low-resolution image
        KingfisherManager.shared.retrieveImage(with: lowResURL) { [weak self] result in
            switch result {
            case .success(let value):
                // Use the low-resolution image as a placeholder
                self?.imageView.kf.setImage(with: highResURL, placeholder: value.image) { result in
                    UIBlockingProgressHUD.dismiss()
                    switch result {
                    case .success(let highResValue):
                        self?.imageView.image = highResValue.image
                    case .failure:
                        self?.showError()
                    }
                }
            case .failure:
                // If the low-resolution image fails to load, proceed with the high-resolution image
                self?.imageView.kf.setImage(with: highResURL) { result in
                    UIBlockingProgressHUD.dismiss()
                    switch result {
                    case .success(let highResValue):
                        self?.imageView.image = highResValue.image
                    case .failure:
                        self?.showError()
                    }
                }
            }
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    private func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
}

fileprivate extension CGFloat {
    static let shareButtonSize: CGFloat = 50
}
