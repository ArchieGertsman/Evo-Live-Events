//
//  YourProfileHeader.swift
//  Evo
//
//  Created by Admin on 6/10/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

class YourProfileHeader: ProfileHeader {
    
    override func setupViews() {
        super.setupViews()

        self.addSubview(self.edit_profile_button)
        
        self.edit_profile_button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        self.edit_profile_button.bottomAnchor.constraint(equalTo: separatorLineView.topAnchor, constant: -10).isActive = true
        // self.edit_profile_button.widthAnchor.constraint(equalToConstant: 160).isActive = true
        self.edit_profile_button.leftAnchor.constraint(equalTo: self.following_view.rightAnchor, constant: 10).isActive = true
        self.edit_profile_button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.name_label.rightAnchor.constraint(equalTo: edit_profile_button.rightAnchor).isActive = true
    }

    lazy var edit_profile_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .EVO_blue
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Edit Profile", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openEditProfilePage), for: .touchUpInside)
        return button
    }()
}
