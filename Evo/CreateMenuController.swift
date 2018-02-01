//
//  CreateMenuController.swift
//  Evo
//
//  Created by Admin on 6/13/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

/* menu controller with two options: create event or create group */
class CreateMenuController: OverlayMenuController {
    
    private static let diameter_of_button: CGFloat = 150

    // add buttons and respective labels to screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(event_button)
        self.view.addSubview(event_label)
        self.view.addSubview(group_button)
        self.view.addSubview(group_label)
        
        event_button.rightAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -15).isActive = true
        event_button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        event_button.widthAnchor.constraint(equalToConstant: CreateMenuController.diameter_of_button).isActive = true
        event_button.heightAnchor.constraint(equalToConstant: CreateMenuController.diameter_of_button).isActive = true
        
        event_label.topAnchor.constraint(equalTo: event_button.bottomAnchor, constant: 5).isActive = true
        event_label.centerXAnchor.constraint(equalTo: event_button.centerXAnchor).isActive = true
        
        group_button.leftAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 15).isActive = true
        group_button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        group_button.widthAnchor.constraint(equalToConstant: CreateMenuController.diameter_of_button).isActive = true
        group_button.heightAnchor.constraint(equalToConstant: CreateMenuController.diameter_of_button).isActive = true
        
        group_label.topAnchor.constraint(equalTo: group_button.bottomAnchor, constant: 5).isActive = true
        group_label.centerXAnchor.constraint(equalTo: group_button.centerXAnchor).isActive = true
    }
    
    
    /* views */
    
    // event
    
    lazy var event_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_create_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 40, bottom: 30, right: 30)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = CreateMenuController.diameter_of_button / 2.0
        button.addTarget(self, action: #selector(openCreateEventController), for: .touchUpInside)
        return button
    }()
    
    let event_label: UILabel = {
        let label = UILabel()
        label.text = "Event"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()
    
    // group

    lazy var group_button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "menu_group_button_emblem"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 22.5, bottom: 30, right: 22.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = CreateMenuController.diameter_of_button / 2.0
        button.addTarget(self, action: #selector(openCreateGroupController), for: .touchUpInside)
        return button
    }()
    
    let group_label: UILabel = {
        let label = UILabel()
        label.text = "Group"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label
    }()
}
