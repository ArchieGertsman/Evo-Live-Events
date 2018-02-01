//
//  YourProfileHeader.swift
//  Evo
//
//  Created by Admin on 6/10/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

class OthersProfileHeader: ProfileHeader {
    
    enum ButtonMode {
        case follow
        case unfollow
    }
    
    var button_mode: ButtonMode = .follow {
        didSet {
            switch button_mode {
            case .follow:
                follow_button.backgroundColor = .EVO_blue
                follow_button.setTitleColor(.white, for: .normal)
                follow_button.setTitle("Follow", for: .normal)
                follow_button.layer.borderWidth = 0
               
            case .unfollow:
                follow_button.backgroundColor = .white
                follow_button.setTitleColor(.EVO_blue, for: .normal)
                follow_button.setTitle("Unfollow", for: .normal)
                follow_button.layer.borderColor = UIColor.EVO_blue.cgColor
                follow_button.layer.borderWidth = 1
                
            }
        }
    }
    
    override var datasourceItem: Any? {
        didSet {
            guard let current_uid = Auth.auth().currentUser?.uid else { return }
            
            Profile.isFollowing(current_uid, self.profile.id) { (following) in
                self.button_mode = following ? .unfollow : .follow
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.follow_button)
        
        self.follow_button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        self.follow_button.bottomAnchor.constraint(equalTo: separatorLineView.topAnchor, constant: -10).isActive = true
        // self.follow_button.widthAnchor.constraint(equalToConstant: 160).isActive = true
        self.follow_button.leftAnchor.constraint(equalTo: self.following_view.rightAnchor, constant: 10).isActive = true
        self.follow_button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.name_label.rightAnchor.constraint(equalTo: follow_button.rightAnchor).isActive = true
    }
    
    lazy var follow_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 16)
        button.setTitleColor(.EVO_blue, for: .normal)
        button.setTitle("Follow", for: .normal)
        button.layer.borderColor = UIColor.EVO_blue.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return button
    }()
    
}
