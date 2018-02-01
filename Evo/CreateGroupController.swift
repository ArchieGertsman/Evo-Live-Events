//
//  CreateGroupController.swift
//  Evo
//
//  Created by Admin on 6/17/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import KSTokenView

class CreateGroupController: UIViewController, UIScrollViewDelegate {

    typealias NamesDict = Dictionary<String, String>

    let scroll_view = UIScrollView()
    var group_image: UIImage?
    var description_height_constraint: NSLayoutConstraint!
    var names_dict = NamesDict()
    var names: [String] {
        return Array(names_dict.keys)
    }
    
    required init(_ names_dict: NamesDict) {
        self.names_dict = names_dict
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: "Create a Group")
        
        self.name_text_view.delegate = self
        self.description_text_view.delegate = self
        self.scroll_view.delegate = self
        
        self.setUpViews()
        self.setUpConstraints()
    }
    
    // put everything on a scroll view
    private func setUpViews() {
        self.add_members_token_view = TokenView(self.names, field_name: "Add")
        self.add_members_token_view.is_border_enabled = true
        self.add_members_token_view.translatesAutoresizingMaskIntoConstraints = false
        
        self.scroll_view.addSubview(image_view) // group image
        self.scroll_view.addSubview(image_label)
        
        // group name
        self.name_container_view.addSubview(name_container_title)
        self.name_container_view.addSubview(name_text_view)
        self.scroll_view.addSubview(name_container_view)
        
        // group description
        self.description_container_view.addSubview(description_container_title)
        self.description_container_view.addSubview(description_text_view)
        self.scroll_view.addSubview(description_container_view)
        
        // group privacy selector
        self.privacy_container_view.addSubview(privacy_container_title)
        self.privacy_container_view.addSubview(privacy_switch)
        self.privacy_container_view.addSubview(privacy_switch_label)
        self.scroll_view.addSubview(privacy_container_view)
        
        self.scroll_view.addSubview(create_button) // create group button
        self.scroll_view.addSubview(add_members_token_view) // area for adding members to the group
        
        self.view.addSubview(scroll_view)
    }
    
    private func setUpConstraints() {
        constrainNameContainer()
        constrainImageContainer()
        constrainDescriptionContainer()
        constrainAddMembersContainer()
        constrainPrivacyContainer()
        constrainCreateButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scroll_view.frame = view.bounds
        scroll_view.contentSize = CGSize(width: self.view.frame.width, height: create_button.frame.maxY + 100)
    }
    
    /* views */
    
    // group image
    
    lazy var image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.image = #imageLiteral(resourceName: "default_user_image")
        image_view.layer.masksToBounds = true
        image_view.layer.cornerRadius = 85.0 / 2
        image_view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        image_view.layer.borderWidth = 1
        image_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectGroupImage)))
        image_view.isUserInteractionEnabled = true
        return image_view
    }()
    
    lazy var image_label: UILabel = {
        let label = UILabel()
        label.text = "Select Group Image"
        label.textColor = .EVO_blue
        label.font = UIFont(size: 14)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectGroupImage)))
        return label
    }()
    
    // name the group
    
    let name_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let name_container_title: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let name_text_view: UITextView = {
        let text_view = UITextView()
        text_view.backgroundColor = .clear
        text_view.textColor = .lightGray
        text_view.placeholder = "Insert name"
        text_view.text = text_view.placeholder
        text_view.font = UIFont(name: "OpenSans", size: 15)
        text_view.textContainerInset = UIEdgeInsets.zero
        text_view.textContainer.lineFragmentPadding = 0;
        text_view.character_limit = 40
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    // description
    
    let description_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let description_container_title: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let description_text_view: UITextView = {
        let text_view = UITextView()
        text_view.backgroundColor = .clear
        text_view.textColor = .lightGray
        text_view.placeholder = "Insert description"
        text_view.text = text_view.placeholder
        text_view.font = UIFont(name: "OpenSans", size: 15)
        text_view.textContainerInset = .zero
        text_view.textContainer.lineFragmentPadding = 0;
        text_view.character_limit = 114
        text_view.scrollsToTop = false
        text_view.alwaysBounceVertical = false
        text_view.bounces = false
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    // add members
    
    var add_members_token_view: TokenView!
    
    // privacy
    
    let privacy_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let privacy_container_title: UILabel = {
        let label = UILabel()
        label.text = "Privacy"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let privacy_switch_label: UILabel = {
        let label = UILabel()
        label.text = "Private"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let privacy_switch: UISwitch = {
        let ui_switch = UISwitch()
        ui_switch.onTintColor = .EVO_blue
        ui_switch.translatesAutoresizingMaskIntoConstraints = false
        return ui_switch
    }()
    
    // create group button
    
    lazy var create_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.EVO_blue
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 24)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Create", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
        return button
    }()

    
    /* constraints */
    func constrainImageContainer() {
        // image view
        image_view.topAnchor.constraint(equalTo: scroll_view.topAnchor, constant: 10).isActive = true
        image_view.centerXAnchor.constraint(equalTo: scroll_view.centerXAnchor).isActive = true
        image_view.widthAnchor.constraint(equalToConstant: 85).isActive = true
        image_view.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        //image label
        image_label.topAnchor.constraint(equalTo: image_view.bottomAnchor, constant: 5).isActive = true
        image_label.centerXAnchor.constraint(equalTo: image_view.centerXAnchor).isActive = true
    }
    
    func constrainNameContainer() {
        // container
        name_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        name_container_view.topAnchor.constraint(equalTo: image_label.bottomAnchor, constant: 15).isActive = true
        name_container_view.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        // title
        name_container_title.leftAnchor.constraint(equalTo: name_container_view.leftAnchor, constant: 10).isActive = true
        name_container_title.topAnchor.constraint(equalTo: name_container_view.topAnchor, constant: 6).isActive = true
        
        // text view
        name_text_view.leftAnchor.constraint(equalTo: name_container_title.leftAnchor).isActive = true
        name_text_view.topAnchor.constraint(equalTo: name_container_title.bottomAnchor, constant: 3).isActive = true
        name_text_view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        name_text_view.rightAnchor.constraint(equalTo: name_container_view.rightAnchor, constant: -10).isActive = true
        
        name_container_view.bottomAnchor.constraint(equalTo: name_text_view.bottomAnchor, constant: -5).isActive = true
    }
    
    
    func constrainDescriptionContainer() {
        // container
        description_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        description_container_view.topAnchor.constraint(equalTo: name_container_view.bottomAnchor, constant: 15).isActive = true
        description_container_view.widthAnchor.constraint(equalTo: name_container_view.widthAnchor).isActive = true
        
        // title
        description_container_title.leftAnchor.constraint(equalTo: description_container_view.leftAnchor, constant: 10).isActive = true
        description_container_title.topAnchor.constraint(equalTo: description_container_view.topAnchor, constant: 6).isActive = true
        
        // text view
        description_text_view.leftAnchor.constraint(equalTo: description_container_title.leftAnchor).isActive = true
        description_text_view.topAnchor.constraint(equalTo: description_container_title.bottomAnchor, constant: 5).isActive = true
        self.description_height_constraint = description_text_view.heightAnchor.constraint(equalToConstant: 40)
        self.description_height_constraint.isActive = true
        description_text_view.rightAnchor.constraint(equalTo: description_container_view.rightAnchor, constant: -10).isActive = true
        
        description_container_view.bottomAnchor.constraint(equalTo: description_text_view.bottomAnchor, constant: -5).isActive = true
    }
    
    func constrainAddMembersContainer() {
        
        // token view
        add_members_token_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        add_members_token_view.topAnchor.constraint(equalTo: description_container_view.bottomAnchor, constant: 5).isActive = true
        add_members_token_view.widthAnchor.constraint(equalTo: description_container_view.widthAnchor).isActive = true
    }
    
    func constrainPrivacyContainer() {
        // container
        privacy_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        privacy_container_view.topAnchor.constraint(equalTo: add_members_token_view.getBottomAnchorOfInputView(), constant: 15).isActive = true
        privacy_container_view.widthAnchor.constraint(equalTo: add_members_token_view.widthAnchor).isActive = true
        
        // title
        privacy_container_title.leftAnchor.constraint(equalTo: privacy_container_view.leftAnchor, constant: 10).isActive = true
        privacy_container_title.topAnchor.constraint(equalTo: privacy_container_view.topAnchor, constant: 6).isActive = true
        
        // switch
        privacy_switch.centerXAnchor.constraint(equalTo: privacy_container_view.centerXAnchor, constant: privacy_switch.intrinsicContentSize.width).isActive = true
        privacy_switch.topAnchor.constraint(equalTo: privacy_container_title.bottomAnchor, constant: 2).isActive = true
        
        // switch label
        privacy_switch_label.rightAnchor.constraint(equalTo: privacy_switch.leftAnchor, constant: -5).isActive = true
        privacy_switch_label.centerYAnchor.constraint(equalTo: privacy_switch.centerYAnchor).isActive = true
        
        privacy_container_view.bottomAnchor.constraint(equalTo: self.privacy_switch.bottomAnchor, constant: 15).isActive = true
    }
    
    func constrainCreateButton() {
        create_button.topAnchor.constraint(equalTo: privacy_container_view.bottomAnchor, constant: 15).isActive = true
        create_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        create_button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        create_button.widthAnchor.constraint(equalTo: privacy_container_view.widthAnchor).isActive = true
    }
}
