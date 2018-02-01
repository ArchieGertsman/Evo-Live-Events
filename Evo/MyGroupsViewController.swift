//
//  MyGroupsViewController.swift
//  Evo
//
//  Created by Admin on 8/22/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

/* "My Groups" tab for `GroupsTabBarController` */
class MyGroupsViewController: GroupsCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadGroups()
        
        Analytics.setScreenName("my_groups", screenClass: "MyGroupsViewController")
    }
    
    func loadGroups() {
        Database.database().reference().child(DBChildren.user_groups).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject] {
                Group.initGroups(with: Array(dict.keys)) { groups in
                    self.groups = groups
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
        })
    }

}
