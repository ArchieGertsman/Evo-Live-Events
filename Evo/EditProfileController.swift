//
//  EditProfileController.swift
//  Evo
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UIViewController, UIScrollViewDelegate {

    let scroll_view = UIScrollView() // encompases the view, allows for scrolling (obviously)
    let profile: Profile
    var selected_image_fom_picker: UIImage?
    
    /* Dropdown variables */
    
    var age_dropdown = UIPickerView()
    var gender_dropdown = UIPickerView()
    
    // user can select an age in [18, 64] or "65+"
    var ages_array: [String] = {
        var array: [String] = []
        
        for i in 18...64 {
            array.append("\(i)")
        }
        array.append("65+")
        
        return array
    }()
    
    var genders_array = ["Male", "Female"]
    
    required init(with profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initEvoStyle(title: "Edit Profile")
        
        // assign dropdowns to respective text fields
        self.scroll_view.delegate = self
        self.age_dropdown.delegate = self
        self.age_dropdown.dataSource = self
        self.gender_dropdown.delegate = self
        self.gender_dropdown.dataSource = self
        self.profile_information_container_view.delegate = self
        
        self.profile_information_container_view.age_text_field.inputView = age_dropdown
        self.profile_information_container_view.gender_text_field.inputView = gender_dropdown
        
        self.scroll_view.addSubview(profile_image_view)
        self.scroll_view.addSubview(change_picture_button)
        self.scroll_view.addSubview(account_label)
        self.scroll_view.addSubview(profile_information_container_view)
        self.scroll_view.addSubview(update_info_button)
        self.view.addSubview(self.scroll_view)
        
        // constraints
        constrainProfileInformationContainer()
        constrainProfileImageView()
        constrainChangePictureButton()
        constrainAccountLabel()
        constrainUpdateInfoButton()
        
        self.fillInformation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scroll_view.frame = self.view.bounds
        self.scroll_view.contentSize = CGSize(width: self.view.frame.width, height: self.update_info_button.frame.maxY + 100)
    }
    
    ///views
    
    private static let profile_image_diameter: CGFloat = 130.0
    
    /* profile image view */
    
    lazy var profile_image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.masksToBounds = true
        image_view.layer.cornerRadius = EditProfileController.profile_image_diameter / 2.0 // circular image
        image_view.layer.borderWidth = 1
        image_view.layer.borderColor = UIColor.black.cgColor
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
        image_view.isUserInteractionEnabled = true
        
        return image_view
    }()
    
    lazy var change_picture_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("Change Picture", for: .normal)
        button.setTitleColor(.EVO_blue, for: .normal)
        button.titleLabel!.font = UIFont(name: "OpenSans", size: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectProfileImage), for: .touchUpInside)
        return button
    }()
    
    let account_label: UILabel = {
        let label = UILabel()
        label.textColor = .EVO_text_gray
        label.text = "Account"
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let profile_information_container_view = ProfileInformationContainerView()

    let update_info_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.EVO_blue
        button.setTitle("Update", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = UIFont(name: "OpenSans-Bold", size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(updateUserInfoToFirebase), for: .touchUpInside)
        return button
    }()

    /* constraints */
    
    func constrainProfileImageView() {
        profile_image_view.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        profile_image_view.topAnchor.constraint(equalTo: self.scroll_view.topAnchor, constant: 10).isActive = true
        profile_image_view.heightAnchor.constraint(equalToConstant: EditProfileController.profile_image_diameter).isActive = true
        profile_image_view.widthAnchor.constraint(equalTo: profile_image_view.heightAnchor).isActive = true
    }
    
    func constrainChangePictureButton() {
        change_picture_button.centerXAnchor.constraint(equalTo: profile_image_view.centerXAnchor).isActive = true
        change_picture_button.centerYAnchor.constraint(equalTo: profile_image_view.bottomAnchor, constant: 12).isActive = true
    }
    
    func constrainAccountLabel() {
        account_label.bottomAnchor.constraint(equalTo: profile_information_container_view.topAnchor, constant: -3).isActive = true
        account_label.leftAnchor.constraint(equalTo: profile_information_container_view.leftAnchor, constant: 10).isActive = true
    }

    func constrainProfileInformationContainer() {
        profile_information_container_view.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        profile_information_container_view.topAnchor.constraint(equalTo: profile_image_view.bottomAnchor, constant: 40).isActive = true
        profile_information_container_view.widthAnchor.constraint(equalTo: self.scroll_view.widthAnchor, constant: -20).isActive = true
        profile_information_container_view.heightAnchor.constraint(equalToConstant: ProfileInformationContainerView.height).isActive = true
    }

    func constrainUpdateInfoButton() {
        update_info_button.topAnchor.constraint(equalTo: profile_information_container_view.bottomAnchor, constant: 12).isActive = true
        update_info_button.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        update_info_button.widthAnchor.constraint(equalTo: profile_information_container_view.widthAnchor).isActive = true
        update_info_button.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    /* set status bar text to white */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
