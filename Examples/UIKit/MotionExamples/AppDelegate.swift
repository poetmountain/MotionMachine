//
//  AppDelegate.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let master_vc = MasterViewController.init()
        let nav = UINavigationController.init()
        nav.addChild(master_vc)
        window?.rootViewController = nav
        
        window?.makeKeyAndVisible()
        
        return true
    }



}

