//
//  SceneDelegate.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import MapKit
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let myWindow = UIWindow(windowScene: windowScene)
      let navVC = UINavigationController()
      let viewController = MainViewController(coor: nil)
      let emailButton = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise")!,
                                        style: .plain,
                                        target: self,
                                        action: #selector(action))
      viewController.navigationItem.rightBarButtonItem = emailButton
      viewController.title = "Банкоматы"
      navVC.viewControllers = [viewController]
      myWindow.rootViewController = navVC
      self.window = myWindow
      myWindow.makeKeyAndVisible()
    }
  }
  @objc func action() {

  }

}
