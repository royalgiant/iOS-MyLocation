//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Donald Lee on 2015-05-12.
//  Copyright (c) 2015 mylocations. All rights reserved.
//

import UIKit
class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
