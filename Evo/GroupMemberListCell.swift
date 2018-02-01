//
//  GroupMemberListCell.swift
//  Evo
//
//  Created by Admin on 9/3/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

class GroupMemberListCell: ProfileListCell {
    
    func showMemberRemovalButton() {
        guard let follow_button = self.follow_button else { return }
        
        follow_button.backgroundColor = UIColor(r: 230, g: 0, b: 0)
        follow_button.setTitleColor(.white, for: .normal)
        follow_button.setTitle("Remove", for: .normal)
        follow_button.layer.borderColor = UIColor.red.cgColor
        follow_button.removeTarget(self, action: #selector(self.handleFollow), for: .touchUpInside)
        follow_button.addTarget(self, action: #selector(self.removeMember), for: .touchUpInside)
    }
    
    override func showFollowButton() {
        super.showFollowButton()
        self.follow_button?.removeTarget(self, action: #selector(self.removeMember), for: .touchUpInside)
        self.follow_button?.addTarget(self, action: #selector(self.handleFollow), for: .touchUpInside)
    }
    
    @objc private func removeMember() {
        self.controller?.showAlert(title: "Are you sure you would like to remove \(self.profile.name) from this group?", message: nil, acceptence_text: "Yes", cancel: true) { _ in
            Profile.leaveGroup(self.profile.id, (self.controller as! ProfileAndGroupListController).id)
        }
    }
    
}
