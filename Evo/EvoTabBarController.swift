//
//  EvoTabBarController.swift
//  Evo
//
//  Created by Admin on 8/26/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

/* UITabBarController with Evo style, i.e. UITabBar on the top of the screen.
 * Used in main event feed and groups controller */
class EvoTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBarItems()
    }
    
    override func viewWillLayoutSubviews() {
        self.setUpTabBar()
    }
    
    // set up the visuals of the UITabBar
    func setUpTabBar() {
        self.tabBar.frame = CGRect(x: -1, y: 0, width: self.tabBar.frame.size.width + 2, height: self.tabBar.frame.size.height - 10)
        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = .EVO_blue
        self.tabBar.layer.borderColor = UIColor.EVO_text_light_gray.cgColor
        self.tabBar.layer.borderWidth = 1
    }
    
    // override this method to add items to the UITabBar
    func setUpNavigationBarItems() {
        // no items
    }
    
    // returns a controller that is formatted to be properly desplayed in this UITabBarController
    func getSetUpController(from controller: UIViewController, tabTitle: String) -> UINavigationController {
        if let cv = (controller as? UICollectionViewController)?.collectionView {
            cv.frame = CGRect(x: 0, y: self.tabBar.frame.size.height - 10, width: cv.frame.size.width, height: cv.frame.size.height)
        }
        controller.viewController = self
        
        let ret_controller = UINavigationController(rootViewController: controller)
        ret_controller.tabBarItem.title = tabTitle
        ret_controller.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "OpenSans", size: 20)!], for: .normal)
        ret_controller.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        
        return ret_controller
    }
}
