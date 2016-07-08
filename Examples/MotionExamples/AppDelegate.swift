//
//  AppDelegate.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/1/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main().bounds)
        
        let master_vc = MasterViewController.init()
        let nav = UINavigationController.init()
        nav.addChildViewController(master_vc)
        window?.rootViewController = nav
        
        window?.makeKeyAndVisible()
        
        return true
    }




}

