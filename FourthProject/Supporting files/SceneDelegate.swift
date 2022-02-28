//
//  SceneDelegate.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import MapKit
import CoreLocation
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let myWindow = UIWindow(windowScene: windowScene)
      let navVC = UINavigationController()
      let viewController = MainViewController()
      viewController.title = navTitle
      navVC.viewControllers = [viewController]
      myWindow.rootViewController = navVC
      self.window = myWindow
      myWindow.makeKeyAndVisible()
    }
  }
}
