//
//  Group+extensions.swift
//  Evo
//
//  Created by Admin on 6/18/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase
import KSTokenView

extension GroupController {
    
    func observeGroup() {
        self.entity_ref.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            Group.load(with: dictionary) { group in
                guard let group = group else { return }
                
                if let group_datasource = self.datasource as? GroupDatasource {
                    group_datasource.group = group
                } else {
                    Profile.isInGroup(Auth.auth().currentUser!.uid, group.id) { in_group in
                        self.datasource = GroupDatasource(group, is_current_user_in_group: in_group)
                    }
                }
                
                self.observeEvents()
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
}

extension GroupController {
    
    // add header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: GroupHeader.height)
    }
    
}

extension GroupHeader {
    
    func showLeaveAlert() {
        self.controller?.showAlert(
            title: "Are you sure you would like to leave this group?",
            message: nil,
            acceptence_text: "Yes",
            cancel: true
        ) { _ in
            self.button_mode = .join
            _ = self.controller!.navigationController!.popToRootViewController(animated: true)
            Profile.leaveGroup(Auth.auth().currentUser!.uid, self.group.id)
        }
    }
    
    func showDisbandAlert() {
        self.controller?.showAlert(
            title: "Are you sure you would like to disband this group?",
            message: nil,
            acceptence_text: "Yes",
            cancel: true
        ) { _ in
            self.button_mode = .join
            _ = self.controller!.navigationController!.popToRootViewController(animated: true)
            Group.disband(self.group.id)
        }
    }
    
    func showCancelRequestAlert() {
        self.controller?.showAlert(
            title: "Are you sure you would like to cancel your join request?",
            message: nil,
            acceptence_text: "Yes",
            cancel: true
        ) { _ in
            self.button_mode = .join
            PendingRequest.getKey(with: Auth.auth().currentUser!.uid, gid: self.group.id) { prid in
                if let prid = prid {
                    PendingRequest.remove(prid)
                }
            }
        }
    }
    
    @objc internal func handleMembership() {
        guard let current_uid = Auth.auth().currentUser?.uid else { return }
        
        /* if in group then if owner show disband alert or else show leave alert
         * else if not private group then join
         * else either create join request or cancel existing one
         */
        
        Profile.isInGroup(current_uid, self.group.id) { (in_group) in
            if in_group {
                (current_uid == self.group.owner_uid ? self.showDisbandAlert : self.showLeaveAlert)()
            }
            else {
                if !self.group.is_private {
                    self.button_mode = .leave
                    Profile.joinGroup(current_uid, self.group.id)
                }
                else {
                    Profile.isPendingGroup(current_uid, self.group.id) { is_pending in
                        if is_pending {
                            self.showCancelRequestAlert()
                        }
                        else {
                            self.button_mode = .pending
                            Profile.sendPendingRequest(from: current_uid, to: self.group)
                        }
                    }
                }
            }
        }
    }
    
    @objc internal func openMembersListPage() {
        if let nc = UIApplication.getNavigationController() {
            nc.pushViewController(ProfileAndGroupListController(self.group.id, .group_members), animated: true)
        }
    }
    
    @objc internal func createGroupEvent() {
        if let nc = UIApplication.getNavigationController() {
            nc.pushViewController(CreateEventController(self.group), animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        self.controller?.showAlert(title: title, message: message, acceptence_text: "Okay", cancel: false, completion: nil)
    }
    
    private func getNamesDict(_ completion: @escaping (Dictionary<String, String>) -> Void) {
        let ref = Database.database().reference()
        
        ref.child(DBChildren.user_followings).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let following_uids_dict = snapshot.value as? [String : AnyObject] else {
                self.showAlert(title: "Oops!", message: "Looks like you aren't following anyone.")
                return
            }
            let following_uids = Array(following_uids_dict.keys)
            
            ref.child(DBChildren.group_members).child((self.controller! as! GroupController).group.id).observeSingleEvent(of: .value, with: { snapshot in
                guard let memebers_uids_dict = snapshot.value as? [String : AnyObject] else {
                    self.showAlert(title: "Oops!", message: "Something went wrong.")
                    return
                }
                let members_uids = Array(memebers_uids_dict.keys)
                
                let uids = following_uids.filter { !members_uids.contains($0) }
                
                Profile.initProfiles(with: uids) { profiles in
                    
                    var names_dict = Dictionary<String, String>()
                    
                    for profile in profiles {
                        names_dict[profile.name] = profile.id
                    }
                    
                    completion(names_dict)
                }
            })
            
        })
    }
    
    @objc internal func presentAddGroupMembersPopup() {
        
        self.getNamesDict { names_dict in
            let controller = AddGroupMembersController(names_dict, (self.controller! as! GroupController).group.id)
            controller.delegate = self.controller! as? GroupController
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve
            self.controller?.present(controller, animated: true, completion: nil)
        }
        
    }
}

// UI
extension GroupHeader {
    
    func setHeaderLayout(mode: ButtonMode) {
        
        switch mode {
        case .join:
            self.removeMemberAccessibleButtons()
            self.constrainMembershipButtonLeftAnchor(members_button.rightAnchor, constant: 20)
            self.setMembershipButtonStyle(background_color: .EVO_blue, title_color: .white, title: "Join", border_width: 0)
            
        case .leave:
            self.addMemberAccessibleButtons()
            self.constrainMembershipButtonLeftAnchor(self.create_event_button.rightAnchor, constant: 20)
            self.setMembershipButtonStyle(background_color: .white, title_color: .EVO_blue, title: "Leave", border_width: 1)
            
        case .pending:
            self.removeMemberAccessibleButtons()
            self.constrainMembershipButtonLeftAnchor(members_button.rightAnchor, constant: 20)
            self.setMembershipButtonStyle(background_color: .white, title_color: .EVO_blue, title: "Pending", border_width: 1)
            
        case .disband:
            self.addMemberAccessibleButtons()
            self.constrainMembershipButtonLeftAnchor(self.create_event_button.rightAnchor, constant: 20)
            self.setMembershipButtonStyle(background_color: .white, title_color: .EVO_blue, title: "Disband", border_width: 1)
        }
        
    }
    
    func removeMemberAccessibleButtons() {
        self.create_event_button.removeFromSuperview()
        self.add_members_button.removeFromSuperview()
        
        self.create_event_button.removeConstraints(create_event_button.constraints)
        self.add_members_button.removeConstraints(add_members_button.constraints)
    }
    
    func addMemberAccessibleButtons() {
        self.addSubview(create_event_button)
        self.addSubview(add_members_button)
        
        self.add_members_button.centerYAnchor.constraint(equalTo: self.membership_button.centerYAnchor, constant: -3).isActive = true
        self.add_members_button.leftAnchor.constraint(equalTo: self.members_button_label.rightAnchor, constant: 15).isActive = true
        self.add_members_button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.add_members_button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.create_event_button.centerYAnchor.constraint(equalTo: self.add_members_button.centerYAnchor, constant: 5).isActive = true
        self.create_event_button.leftAnchor.constraint(equalTo: self.add_members_button.rightAnchor, constant: 25).isActive = true
        self.create_event_button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.create_event_button.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setMembershipButtonStyle(background_color: UIColor, title_color: UIColor, title: String, border_width: CGFloat) {
        self.membership_button.backgroundColor = background_color
        self.membership_button.setTitleColor(title_color, for: .normal)
        self.membership_button.setTitle(title, for: .normal)
        self.membership_button.layer.borderWidth = border_width
    }
    
    func constrainMembershipButtonLeftAnchor(_ left_anchor: NSLayoutXAxisAnchor, constant: CGFloat) {
        if let constraint = self.membership_button_left_anchor_constraint {
            constraint.isActive = false
        }
        
        self.membership_button_left_anchor_constraint = self.membership_button.leftAnchor.constraint(equalTo: left_anchor, constant: constant)
        self.membership_button_left_anchor_constraint.isActive = true
    }
    
}
