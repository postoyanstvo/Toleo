import UIKit
 
final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor.ypWhite
        tabBar.barTintColor = UIColor.ypBlack
        tabBar.backgroundColor = UIColor.ypBlack
        tabBar.isTranslucent = false
        
        let imagesListVC = ImagesListViewController()
        imagesListVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "square.stack"),
            selectedImage: UIImage(systemName: "square.stack.fill")
        )
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle"))
        
        viewControllers = [imagesListVC, profileVC]
    }
}
