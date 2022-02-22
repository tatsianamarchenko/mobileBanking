//
//  SceneDelegate.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    if let ws = scene as? UIWindowScene {
      let myWindow = UIWindow(windowScene: ws)
      let navVC = UINavigationController()
      let vc = MainViewController()
      let emailButton = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise")!,
                                        style: .plain,
                                        target: self,
                                        action: #selector(action))
      vc.navigationItem.rightBarButtonItem = emailButton
      vc.title = "Банкоматы"
      navVC.viewControllers = [vc]
      myWindow.rootViewController = navVC
      self.window = myWindow
      myWindow.makeKeyAndVisible()
    }
  }
  @objc func action() {}

}
