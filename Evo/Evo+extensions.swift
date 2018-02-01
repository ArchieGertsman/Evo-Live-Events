//
//  Evo+handlers.swift
//  Evo
//
//  Created by Admin on 3/31/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

extension EvoOverlay {
    
    @objc class func handleButtonClick() {
        OverlayMenuController.is_open ?
            (UIApplication.topViewController() as? OverlayMenuController)?.dismissWithoutCompletion()
            : EvoOverlay.open()
    }
    
    private class func open() {
        guard let top_controller = UIApplication.topViewController() else { return }
        top_controller.dismissKeyboard()
        let menu_controller = EvoMenuController()
        menu_controller.modalPresentationStyle = .overFullScreen // allows current view to be visible underneath evo menu controller
        menu_controller.view.alpha = 0.0
        
        // present
        top_controller.present(menu_controller, animated: false) {
            UIView.animate(withDuration: 0.15) {
                menu_controller.view.alpha = 1.0
                OverlayMenuController.is_open = true
            }
        }
    }
    
}
extension EvoMenuController {
    
    @objc internal func openEntitySearchController() {
        OverlayMenuController.is_open = false
        
        self.dismiss { 
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            
            for controller in nc.viewControllers as Array {
                if controller.isKind(of: EntitySearchController.self) {
                    if !tvc.isKind(of: EvoMenuController.self) {
                        tvc.dismiss(animated: true, completion: nil)
                    }
                    nc.popToViewController(controller, animated: true)
                    return
                }
            }
            
            if !tvc.isKind(of: EvoMenuController.self) {
                tvc.dismiss(animated: true, completion: nil)
            }
            nc.pushViewController(EntitySearchController(), animated: true)
        }
    }
    
    @objc internal func openProfileController() {
        OverlayMenuController.is_open = false
        
        self.dismiss {
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            
            print(type(of: tvc))
            
            for controller in nc.viewControllers as Array {
                if controller.isKind(of: ProfileController.self) && (controller as! ProfileController).profile_type == .current_user {
                    if !tvc.isKind(of: EvoMenuController.self) {
                        tvc.dismiss(animated: true, completion: nil)
                    }
                    nc.popToViewController(controller, animated: true)
                    return
                }
            }
            
            guard let current_uid = Auth.auth().currentUser?.uid else { return }
            if !tvc.isKind(of: EvoMenuController.self) {
                tvc.dismiss(animated: true, completion: nil)
            }
            Profile.initProfile(with: current_uid) { profile in
                if let profile = profile {
                    nc.pushViewController(ProfileController(of: profile), animated: true)
                }
            }
        }
    }
    
    @objc internal func openSettingsController() {
        OverlayMenuController.is_open = false
        
        self.dismiss {
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            
            for controller in nc.viewControllers as Array {
                if controller.isKind(of: SettingsController.self) {
                    if !tvc.isKind(of: EvoMenuController.self) {
                        tvc.dismiss(animated: true, completion: nil)
                    }
                    nc.popToViewController(controller, animated: true)
                    return
                }
            }
            
            if !tvc.isKind(of: EvoMenuController.self) {
                tvc.dismiss(animated: true, completion: nil)
            }
            nc.pushViewController(SettingsController(), animated: true)
        }
    }
    
    @objc internal func popToFeedController() {
        OverlayMenuController.is_open = false
        
        self.dismiss {
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            if !tvc.isKind(of: EvoMenuController.self) {
                tvc.dismiss(animated: true, completion: nil)
            }
            nc.popToRootViewController(animated: true)
        }
    }
    
    @objc internal func openCreateMenuController() {
        
        self.dismiss(animated: false) {
            CreateMenuController.present()
        }
    }
    
    @objc internal func openMapController() {
        OverlayMenuController.is_open = false
        
        self.dismiss {
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            
            for controller in nc.viewControllers as Array {
                if let controller = controller as? MainEventFeedTabBarController, controller.display_mode == .map {
                    if !(tvc is EvoMenuController) {
                        tvc.dismiss(animated: true, completion: nil)
                    }
                    nc.popToViewController(controller, animated: true)
                    return
                }
            }
            
            if !(tvc is EvoMenuController) {
                tvc.dismiss(animated: true, completion: nil)
            }
            nc.pushViewController(MainEventFeedTabBarController(mode: .map), animated: true)
        }
        
    }
    
    @objc internal func openGroupsController() {
        OverlayMenuController.is_open = false
        
        self.dismiss {
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            
            for controller in nc.viewControllers as Array {
                if controller.isKind(of: GroupsTabBarController.self) {
                    if !tvc.isKind(of: EvoMenuController.self) {
                        tvc.dismiss(animated: true, completion: nil)
                    }
                    nc.popToViewController(controller, animated: true)
                    return
                }
            }
            
            if !tvc.isKind(of: EvoMenuController.self) {
                tvc.dismiss(animated: true, completion: nil)
            }
            nc.pushViewController(GroupsTabBarController(), animated: true)
        }
    }
    
}
