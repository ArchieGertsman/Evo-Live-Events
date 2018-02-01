//
//  GroupRecommendationsViewController.swift
//  Evo
//
//  Created by Admin on 8/25/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

/* "Explore" tab for `GroupsTabBarController` */
class GroupExploreController: GroupsCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadGroups()
        
        Analytics.setScreenName("explore_groups", screenClass: "GroupExploreController")
    }
    
    // loads all the groups in the database that the current user is not in (dumb but hey.. it's the MVP)
    func loadGroups() {
        let ref = Database.database().reference()
        
        ref.child(DBChildren.user_groups).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let dict = snapshot.value as? [String: AnyObject] ?? [String: AnyObject]()
                
            ref.child(DBChildren.groups).observeSingleEvent(of: .value, with: { snapshot in
                if let groups_dict = snapshot.value as? [String: AnyObject] {
                    
                    let groups_keys = Array(groups_dict.keys).filter { !Array(dict.keys).contains($0) }
                    
                    Group.initGroups(with: groups_keys) { groups in
                        self.groups = groups
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                }
            })
        })
        
    }
    
}
