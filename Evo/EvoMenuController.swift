//
//  EvoMenuController.swift
//  Evo
//
//  Created by Admin on 3/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

class EvoMenuController: OverlayMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.search_button)
        self.view.addSubview(self.settings_button)
        self.view.addSubview(self.groups_button)
        self.view.addSubview(self.map_button)
        
        self.view.addSubview(self.profile_button)
        self.view.addSubview(self.profile_label)
        self.view.addSubview(self.groups_label)
        self.view.addSubview(self.map_label)
        self.view.addSubview(self.feed_button)
        self.view.addSubview(self.feed_label)
        self.view.addSubview(self.create_button)
        self.view.addSubview(self.create_label)
        
        self.constrainButtons()
        self.constrainLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNotificationBadge()
    }
    
    func addNotificationBadge() {
        let dispatch_group = DispatchGroup()
        var num_notifications: UInt = 0
        
        dispatch_group.enter()
        PendingRequest.getNumberOfRequests(forUID: Auth.auth().currentUser!.uid) { num in
            if num > 0 {
                num_notifications = num
            }
            dispatch_group.leave()
        }
        
        dispatch_group.enter()
        Event.getNumberOfInvitations(forUID: Auth.auth().currentUser!.uid) { num in
            if num > 0 {
                num_notifications = num
            }
            dispatch_group.leave()
        }
        
        dispatch_group.notify(queue: .main) {
            guard num_notifications > 0 else { return }
            
            UIApplication.shared.applicationIconBadgeNumber = Int(num_notifications)
            
            let invitations_badge = NotificationBadge(num: num_notifications, diameter: 17.0)
            invitations_badge.translatesAutoresizingMaskIntoConstraints = false
            
            self.settings_button.addSubview(invitations_badge)
            
            invitations_badge.centerYAnchor.constraint(equalTo: self.settings_button.imageView!.topAnchor, constant: 3).isActive = true
            invitations_badge.centerXAnchor.constraint(equalTo: self.settings_button.imageView!.leftAnchor).isActive = true
            invitations_badge.widthAnchor.constraint(equalToConstant: invitations_badge.diameter).isActive = true
            invitations_badge.heightAnchor.constraint(equalToConstant: invitations_badge.diameter).isActive = true
        }
    }
    
    /* views */
    
    static let dimension_of_button: CGFloat = UIApplication.shared.keyWindow!.frame.size.width * 3.0/11.0
    static let dimension_of_feed_button: CGFloat = UIApplication.shared.keyWindow!.frame.size.width * 1.0/3.0
    
    /// search button
    
    let search_button: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "search_emblem"), for: .normal)
        button.isExclusiveTouch = true
        button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 30, 30)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openEntitySearchController), for: .touchUpInside)
        return button
    }()
    
    /// settings button
    
    let settings_button: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu_settings_button_emblem"), for: .normal)
        button.isExclusiveTouch = true
        button.imageEdgeInsets = UIEdgeInsetsMake(10, 30, 30, 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openSettingsController), for: .touchUpInside)
        return button
    }()
    
    /// profile button
    let profile_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_profile_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 17, left: 23, bottom: 23, right: 23)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = dimension_of_button / 2.0
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openProfileController), for: .touchUpInside)
        return button
    }()
    
    /// profile label
    let profile_label: UILabel = {
        let label = UILabel()
        label.text = "My Profile"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()
    
    /// groups button
    let groups_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_group_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = dimension_of_button / 2.0
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openGroupsController), for: .touchUpInside)
        return button
    }()
    
    /// groups label
    let groups_label: UILabel = {
        let label = UILabel()
        label.text = "Groups"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()

    /// map button
    let map_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_map_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = dimension_of_button / 2.0
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openMapController), for: .touchUpInside)
        return button
    }()
    
    /// map label
    let map_label: UILabel = {
        let label = UILabel()
        label.text = "Map"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()
    
    /// feed button
    let feed_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_feed_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 35, left: 30, bottom: 35, right: 30)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = dimension_of_feed_button / 2.0
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(popToFeedController), for: .touchUpInside)
        return button
    }()
    
    /// feed label
    let feed_label: UILabel = {
        let label = UILabel()
        label.text = "Feed"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()
    
    /// create button
    let create_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_create_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 15)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = dimension_of_button / 2.0
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openCreateMenuController), for: .touchUpInside)
        return button
    }()
    
    /// create label
    let create_label: UILabel = {
        let label = UILabel()
        label.text = "Create"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()


    
    /* constraints */
    
    func constrainButtons() {
        
        let small_button_dimension: CGFloat = 70.0
        
        // search
        search_button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        search_button.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        search_button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        search_button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // settings
        settings_button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        settings_button.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        settings_button.widthAnchor.constraint(equalToConstant: small_button_dimension).isActive = true
        settings_button.heightAnchor.constraint(equalToConstant: small_button_dimension).isActive = true
        
        // feed
        feed_button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        feed_button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        feed_button.widthAnchor.constraint(equalToConstant: EvoMenuController.dimension_of_feed_button).isActive = true
        feed_button.heightAnchor.constraint(equalTo: feed_button.widthAnchor).isActive = true
        
        let button_x_margin_constant = (UIApplication.shared.keyWindow!.frame.size.width / 2.0 - EvoMenuController.dimension_of_button) / 2.0

        let scrh = UIApplication.shared.keyWindow!.frame.size.height
        let small_button_dimension_modified = small_button_dimension - self.settings_button.imageEdgeInsets.bottom
        let status_bar_height = UIApplication.shared.statusBarFrame.height
        
        let top_button_y_margin_constant = ((scrh - 5 * EvoMenuController.dimension_of_button) / 2.0 - (small_button_dimension_modified + status_bar_height)) / 2.0
        let bottom_button_y_margin_constant = ((scrh - 3 * EvoMenuController.dimension_of_button) / 2.0 + (EvoOverlay.height_of_copyright_bar)) / 2.0
            
        // groups
        groups_button.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: button_x_margin_constant).isActive = true
        groups_button.rightAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -button_x_margin_constant).isActive = true
        
        groups_button.topAnchor.constraint(equalTo: self.settings_button.bottomAnchor, constant: top_button_y_margin_constant).isActive = true
        
        groups_button.widthAnchor.constraint(equalToConstant: EvoMenuController.dimension_of_button).isActive = true
        groups_button.heightAnchor.constraint(equalTo: groups_button.widthAnchor).isActive = true
        
        // map
        map_button.leftAnchor.constraint(equalTo: self.view.centerXAnchor, constant: button_x_margin_constant).isActive = true
        map_button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -button_x_margin_constant).isActive = true
        map_button.centerYAnchor.constraint(equalTo: self.groups_button.centerYAnchor).isActive = true
        map_button.widthAnchor.constraint(equalToConstant: EvoMenuController.dimension_of_button).isActive = true
        map_button.heightAnchor.constraint(equalTo: map_button.widthAnchor).isActive = true

        // profile
        profile_button.centerXAnchor.constraint(equalTo: self.groups_button.centerXAnchor).isActive = true
        
        profile_button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -bottom_button_y_margin_constant).isActive = true
        
        profile_button.widthAnchor.constraint(equalToConstant: EvoMenuController.dimension_of_button).isActive = true
        profile_button.heightAnchor.constraint(equalTo: profile_button.widthAnchor).isActive = true
        
        // create
        create_button.centerXAnchor.constraint(equalTo: self.map_button.centerXAnchor).isActive = true
        create_button.centerYAnchor.constraint(equalTo: self.profile_button.centerYAnchor).isActive = true
        create_button.widthAnchor.constraint(equalToConstant: EvoMenuController.dimension_of_button).isActive = true
        create_button.heightAnchor.constraint(equalTo: create_button.widthAnchor).isActive = true
    }
    
    func constrainLabels() {
        // crowds
        groups_label.centerXAnchor.constraint(equalTo: groups_button.centerXAnchor).isActive = true
        groups_label.topAnchor.constraint(equalTo: groups_button.bottomAnchor, constant: 3).isActive = true
        
        // map
        map_label.centerXAnchor.constraint(equalTo: map_button.centerXAnchor).isActive = true
        map_label.topAnchor.constraint(equalTo: map_button.bottomAnchor, constant: 3).isActive = true
        
        // feed
        feed_label.centerXAnchor.constraint(equalTo: feed_button.centerXAnchor).isActive = true
        feed_label.topAnchor.constraint(equalTo: feed_button.bottomAnchor, constant: 3).isActive = true
        
        // profile
        profile_label.centerXAnchor.constraint(equalTo: profile_button.centerXAnchor).isActive = true
        profile_label.topAnchor.constraint(equalTo: profile_button.bottomAnchor, constant: 3).isActive = true
        
        // create
        create_label.centerXAnchor.constraint(equalTo: create_button.centerXAnchor).isActive = true
        create_label.topAnchor.constraint(equalTo: create_button.bottomAnchor, constant: 3).isActive = true
    }
    
}

