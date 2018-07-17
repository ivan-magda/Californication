//
//  UIViewController+PreferredStatusBarStyle.swift
//  Californication
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Ivan Magda. All rights reserved.
//

import UIKit

extension UINavigationController {
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
  }
}

extension UITabBarController {
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return selectedViewController?.preferredStatusBarStyle ?? .default
  }
}
