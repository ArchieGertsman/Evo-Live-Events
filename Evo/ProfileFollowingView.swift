//
//  ProfileFollowingView.swift
//  Evo
//
//  Created by Admin on 6/10/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

class ProfileFollowingView: UIView {
    
    static let width: CGFloat = 180
    static let height: CGFloat = 48
    private static let label_text_size = ProfileFollowingView.width / 15.5
    static let gray = UIColor(r: 230, g: 230, b: 230, a: 255)
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: ProfileFollowingView.width, height: ProfileFollowingView.height))
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthAnchor.constraint(equalToConstant: ProfileFollowingView.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: ProfileFollowingView.height).isActive = true
        
        self.addSubview(groups_label)
        self.addSubview(followers_label)
        self.addSubview(following_label)
        self.addSubview(groups_button)
        self.addSubview(followers_button)
        self.addSubview(following_button)
        
        // labels
        groups_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        groups_label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        followers_label.leftAnchor.constraint(equalTo: groups_label.rightAnchor, constant: 7).isActive = true
        followers_label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        following_label.leftAnchor.constraint(equalTo: followers_label.rightAnchor, constant: 7).isActive = true
        following_label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        // buttons
        
        groups_button.centerXAnchor.constraint(equalTo: groups_label.centerXAnchor).isActive = true
        groups_button.bottomAnchor.constraint(equalTo: groups_label.topAnchor).isActive = true
        groups_button.widthAnchor.constraint(equalTo: groups_label.widthAnchor).isActive = true
        groups_button.heightAnchor.constraint(equalToConstant: groups_button.intrinsicContentSize.height - 10).isActive = true
        
        followers_button.centerXAnchor.constraint(equalTo: followers_label.centerXAnchor).isActive = true
        followers_button.bottomAnchor.constraint(equalTo: followers_label.topAnchor).isActive = true
        followers_button.widthAnchor.constraint(equalTo: followers_label.widthAnchor).isActive = true
        followers_button.heightAnchor.constraint(equalToConstant: followers_button.intrinsicContentSize.height - 10).isActive = true
        
        following_button.centerXAnchor.constraint(equalTo: following_label.centerXAnchor).isActive = true
        following_button.bottomAnchor.constraint(equalTo: following_label.topAnchor).isActive = true
        following_button.widthAnchor.constraint(equalTo: following_label.widthAnchor).isActive = true
        following_button.heightAnchor.constraint(equalToConstant: following_button.intrinsicContentSize.height - 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* views */
    
    // labels
    
    lazy var groups_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 12)
        label.textColor = .EVO_text_gray
        label.text = "Groups"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followers_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 12)
        label.textColor = .EVO_text_gray
        label.text = "Followers"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var following_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 12)
        label.textColor = .EVO_text_gray
        label.text = "Following"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // buttons
    
    lazy var groups_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.titleLabel?.textColor = .EVO_text_gray
        button.setTitle("", for: .normal)
        button.setTitleColor(.EVO_text_gray, for: .normal)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openGroupsListPage), for: .touchUpInside)
        return button
    }()
    
    lazy var followers_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.setTitle("", for: .normal)
        button.setTitleColor(.EVO_text_gray, for: .normal)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openFollowersListPage), for: .touchUpInside)
        return button
    }()
    
    lazy var following_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.setTitle("", for: .normal)
        button.setTitleColor(.EVO_text_gray, for: .normal)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openFollowingListPage), for: .touchUpInside)
        return button
    }()
    
}
