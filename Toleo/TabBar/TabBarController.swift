import UIKit
 
final class TabBarController: UITabBarController {
       override func awakeFromNib() {
           super.awakeFromNib()
           let storyboard = UIStoryboard(name: "Main", bundle: .main)
           
           let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
           imagesListViewController.tabBarItem = UITabBarItem(
               title: nil,
               image: UIImage(named: "ActiveFeedTab"),
               selectedImage: nil
           )
           let profileViewController = ProfileViewController()
           profileViewController.tabBarItem = UITabBarItem(
               title: nil,
               image: UIImage(named: "ActiveProfileTab"),
               selectedImage: nil
           )
           
           self.viewControllers = [imagesListViewController, profileViewController]
       }
   }
