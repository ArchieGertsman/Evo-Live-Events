//
//  ProfileFollowingListController.swift
//  Evo
//
//  Created by Admin on 6/21/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

/* shows a list of profiles */
class ProfileAndGroupListController: EntityListController {
    
    // types of profile lists to display
    enum ListType {
        case followers
        case followings
        case groups
        case group_members
    }
    
    let list_type: ListType
    var group: Group? // in case of group members list
    
    required init(_ id: String, _ list_type: ListType) {
        self.list_type = list_type
        super.init(id)
    }
    
    required init(_ id: String) {
        fatalError("init has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set things up based on the time of list
        switch list_type {
        case .followers:
            self.setUpElements(controller_title: "Followers", firebase_path: DBChildren.user_followers, datasource: ProfileListDatasource())
            
        case .followings:
            self.setUpElements(controller_title: "Following", firebase_path: DBChildren.user_followings, datasource: ProfileListDatasource())
            
        case .groups:
            self.setUpElements(controller_title: "Groups", firebase_path: DBChildren.user_groups, datasource: GroupListDatasource())
            
        case .group_members:
            self.setUpElements(controller_title: "Members", firebase_path: DBChildren.group_members, datasource: ProfileListDatasource(forGroup: true))
            
            // make sure to retrieve the info about this group of this is a group members list
            Group.initGroup(with: self.id) { group in
                self.group = group
                
                // if this is the group owner then grant permission to remove users
                if let group = self.group, Auth.auth().currentUser!.uid == group.owner_uid {
                    DispatchQueue.main.async {
                        self.setRightBarButtonItemToRemove()
                    }
                }
            }
        }
    }
    
    private func setUpElements(controller_title: String, firebase_path: String, datasource: Datasource) {
        self.initEvoStyle(title: controller_title)
        self.entities_ref = Database.database().reference().child(firebase_path).child(self.id)
        self.datasource = datasource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // observe changes to the dtatbase node containing the profiles for this list.
        // if an ID is added then add that profile to this list
        self.observeAddedEntities { id in
            switch self.list_type {
                
            case .followers, .followings, .group_members:
                Profile.initProfile(with: id) { profile in
                    guard let profile = profile, let people_list_datasource = self.datasource as? ProfileListDatasource else { return }
                    
                    if !people_list_datasource.profiles.contains { return $0.id == profile.id } {
                        people_list_datasource.profiles.append(profile)
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
            case .groups:
                Group.initGroup(with: id) { group in
                    guard let group = group, let groups_list_datasource = self.datasource as? GroupListDatasource else { return }
                    
                    if !groups_list_datasource.groups.contains { return $0.id == group.id } {
                        groups_list_datasource.groups.append(group)
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
        
        /* observe added/removed members if group member page, because if remove members as the owner of a group, then
         this list needs to update */
        if self.list_type == .group_members {
            self.observeMembers()
        }
    }
    
    // group member list handlers
    @objc private func showMemberRemovalButtonsInCells() {
        for cell in self.collectionView!.visibleCells {
            if let cell = cell as? GroupMemberListCell {
                cell.showMemberRemovalButton()
            }
        }
        
        self.setRightBarButtonItemToCancel()
    }
    @objc private func cancelMemberRemoval() {
        for cell in self.collectionView!.visibleCells {
            if let cell = cell as? GroupMemberListCell {
                cell.showFollowButton()
            }
        }
        
        self.setRightBarButtonItemToRemove()
    }
    
}

// extension that deals with the case of a group member list
extension ProfileAndGroupListController {
    
    internal func setRightBarButtonItemToRemove() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(self.showMemberRemovalButtonsInCells))
    }
    
    internal func setRightBarButtonItemToCancel() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelMemberRemoval))
    }
    
    internal func observeMembers() {
        self.observeAddedMembers() // I'm not sure why I'm observing added members, as it isn't totally necessary, but I'll keep it
        self.observeRemovedMembers()
    }
    
    internal func observeAddedMembers() {
        self.observeAddedEntities { id in
            Profile.initProfile(with: id) { profile in
                guard let profile = profile, let people_list_datasource = self.datasource as? ProfileListDatasource else { return }
                
                if !people_list_datasource.profiles.contains { return $0.id == profile.id } {
                    people_list_datasource.profiles.append(profile)
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    internal func observeRemovedMembers() {
        self.observeRemovedEntities { id in
            Profile.initProfile(with: id) { profile in
                print("removed")
                guard let profile = profile, let people_list_datasource = self.datasource as? ProfileListDatasource else { return }
                
                if let idx = (people_list_datasource.profiles.index { $0.id == profile.id }) {
                    people_list_datasource.profiles.remove(at: idx)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.setRightBarButtonItemToRemove()
                    }
                }
            }
        }
    }
    
}
