//
//  GroupsTabBarController.swift
//  Evo
//
//  Created by Admin on 8/22/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

/* hub for groups. Shows "My Groups" and "Explore" tabs */
class GroupsTabBarController: EvoTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: "Groups")
        
        self.viewControllers = [
            getSetUpController(from: MyGroupsViewController(), tabTitle: "My Groups"),
            getSetUpController(from: GroupExploreController(), tabTitle: "Explore")
        ]
    }

    override func setUpNavigationBarItems() {
        //create button
        let create_button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        create_button.setBackgroundImage(#imageLiteral(resourceName: "feed_create_emblem").withRenderingMode(.alwaysTemplate), for: .normal)
        create_button.addTarget(self, action: #selector(openCreateGroupController), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: create_button)
        
        //search button
        let search_button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        search_button.setBackgroundImage(#imageLiteral(resourceName: "feed_search_emblem").withRenderingMode(.alwaysTemplate), for: .normal)
        search_button.addTarget(self, action: #selector(openSearchController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: search_button)
    }
    
    @objc func openSearchController() {
        // first, cycle through all the controllers in the stack. If search controller is already open then go there.
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: EntitySearchController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                return
            }
        }
        
        self.navigationController!.pushViewController(EntitySearchController(), animated: true)
    }
    
    // just a part of the code for opening the controller
    func openCreateGroupControllerHelper(controller: UIViewController) {
        // cycle like in `openSearchController`
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: CreateGroupController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                return
            }
        }
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    @objc private func openCreateGroupController() {
        Database.database().reference().child(DBChildren.user_followings).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let uids_dict = snapshot.value as? [String : AnyObject] else {
                // no followings
                self.openCreateGroupControllerHelper(controller: CreateGroupController(Dictionary<String, String>()))
                return
            }
            let uids = Array(uids_dict.keys)
            
            Profile.initProfiles(with: uids, completion: { (profiles) in
                
                var names_dict = Dictionary<String, String>()
                
                for profile in profiles {
                    names_dict[profile.name] = profile.id
                }
                
                self.openCreateGroupControllerHelper(controller: CreateGroupController(names_dict))
            })
        })
    }
}
