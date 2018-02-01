//
//  CreateMenu+extensions.swift
//  Evo
//
//  Created by Admin on 6/13/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

extension CreateMenuController {
    
    internal func openCreationController(controller: UIViewController) {
        OverlayMenuController.is_open = false
        
        self.dismiss {
            guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
            
            if !tvc.isKind(of: type(of: controller)) {
                nc.pushViewController(controller, animated: true)
                tvc.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc internal func openCreateEventController() {
        
        var users_dict = Dictionary<String, String>()
        var groups_dict = Dictionary<String, String>()
        
        let dispatch_group = DispatchGroup()
        
        // get followings
        
        dispatch_group.enter()
        Database.database().reference().child(DBChildren.user_followings).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let uids_dict = snapshot.value as? [String : AnyObject] {
                let uids = Array(uids_dict.keys)
                
                dispatch_group.enter()
                Profile.initProfiles(with: uids) { profiles in
                    
                    for profile in profiles {
                        users_dict[profile.name] = profile.id
                    }
                    
                    dispatch_group.leave()
                }
            }
            dispatch_group.leave()
        })
        
        // get groups
        
        dispatch_group.enter()
        Database.database().reference().child(DBChildren.user_groups).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let gids_dict = snapshot.value as? [String : AnyObject] {
                let gids = Array(gids_dict.keys)
                
                dispatch_group.enter()
                Group.initGroups(with: gids) { groups in
                    
                    for group in groups {
                        groups_dict[group.name] = group.id
                    }
                    
                    dispatch_group.leave()
                }
            }
            dispatch_group.leave()
        })
        
        dispatch_group.notify(queue: .main) {
            self.openCreationController(controller: CreateEventController(users_dict, groups_dict))
        }
        
    }
    
    @objc internal func openCreateGroupController() {
        Database.database().reference().child(DBChildren.user_followings).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let uids_dict = snapshot.value as? [String : AnyObject] else {
                // no followings
                self.openCreationController(controller: CreateGroupController(Dictionary<String, String>()))
                return
            }
            let uids = Array(uids_dict.keys)
            
            Profile.initProfiles(with: uids, completion: { (profiles) in
                
                var names_dict = Dictionary<String, String>()
                
                for profile in profiles {
                    names_dict[profile.name] = profile.id
                }
                
                self.openCreationController(controller: CreateGroupController(names_dict))
            })
        })
        
        
    }
    
    static func present() {
        guard let top_controller = UIApplication.topViewController() else { return }
        top_controller.dismissKeyboard()
        let evo_menu_controller = CreateMenuController()
        evo_menu_controller.modalPresentationStyle = .overFullScreen // allows current view to be visible underneath evo menu controller
        
        // present
        top_controller.present(evo_menu_controller, animated: false)
    }
    
}
