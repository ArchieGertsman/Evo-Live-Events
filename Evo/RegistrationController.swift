//
//  RegistrationController.swift
//  Project
//
//  Created by Admin on 3/14/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import FontAwesome_swift

class RegistrationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: "Registration")
        
        view.addSubview(login_background_image)
        view.addSubview(registration_title)
        view.addSubview(name_text_field)
        view.addSubview(email_text_field)
        view.addSubview(password_text_field)
        view.addSubview(password_confirmation_text_field)
        view.addSubview(return_to_login_button)
        view.addSubview(registration_button)
        
        constrainLoginBackgroundImage()
        constrainRegistrationTitle()
        constrainNameInputField()
        constrainEmailInputField()
        constrainPasswordInputField()
        constrainPasswordConfirmationInputField()
        constrainReturnToLoginButton()
        constrainRegistrationButton()
    }


    let login_background_image: UIImageView = {
        let image_view = UIImageView()
        image_view.image = UIImage(named: "login_background")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()
    
    let registration_title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 33)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Create Account"
        return label
    }()
    
    /* name field */
    
    let name_text_field : SkyFloatingLabelTextFieldWithIcon = {
        let text_field = SkyFloatingLabelTextFieldWithIcon()
        text_field.placeholder = "name"
        text_field.placeholderColor = .white
        text_field.placeholderFont = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.font = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.iconFont = UIFont(name: "FontAwesome", size: 21)
        text_field.iconText = String.fontAwesomeIcon(code: "fa-user")
        text_field.iconMarginLeft = 8.0
        text_field.iconMarginBottom = 6.0
        text_field.iconColor = .white
        text_field.tintColor = .white
        text_field.textColor = .white
        text_field.lineColor = .white
        text_field.titleColor = .white
        text_field.selectedTitleColor = .white
        text_field.selectedLineColor = .white
        text_field.selectedIconColor = .white
        text_field.lineHeight = 1.0 // bottom line height in points
        text_field.selectedLineHeight = 2.0
        text_field.errorColor = UIColor(r: 215, g: 0, b: 0)
        text_field.autocapitalizationType = .none
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    /* email field */
    
    let email_text_field : SkyFloatingLabelTextFieldWithIcon = {
        let text_field = SkyFloatingLabelTextFieldWithIcon()
        text_field.placeholder = "email"
        text_field.placeholderColor = .white
        text_field.placeholderFont = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.font = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.iconFont = UIFont(name: "FontAwesome", size: 18)
        text_field.iconText = String.fontAwesomeIcon(code: "fa-envelope")
        text_field.iconMarginLeft = 9.0
        text_field.iconMarginBottom = 6.0
        text_field.iconColor = .white
        text_field.tintColor = .white
        text_field.textColor = .white
        text_field.lineColor = .white
        text_field.titleColor = .white
        text_field.selectedTitleColor = .white
        text_field.selectedLineColor = .white
        text_field.selectedIconColor = .white
        text_field.lineHeight = 1.0 // bottom line height in points
        text_field.selectedLineHeight = 2.0
        text_field.errorColor = UIColor(r: 215, g: 0, b: 0)
        text_field.autocapitalizationType = .none
        text_field.translatesAutoresizingMaskIntoConstraints = false
        text_field.keyboardType = UIKeyboardType.emailAddress
        return text_field
    }()
    
    /* password field */
    
    let password_text_field : SkyFloatingLabelTextFieldWithIcon = {
        let text_field = SkyFloatingLabelTextFieldWithIcon()
        text_field.placeholder = "password"
        text_field.placeholderColor = .white
        text_field.placeholderFont = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.font = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.iconFont = UIFont(name: "FontAwesome", size: 21)
        text_field.iconText = String.fontAwesomeIcon(code: "fa-lock")
        text_field.iconMarginLeft = 8.0
        text_field.iconColor = .white
        text_field.tintColor = .white
        text_field.textColor = .white
        text_field.lineColor = .white
        text_field.selectedIconColor = .white
        text_field.titleColor = .white
        text_field.selectedTitleColor = .white
        text_field.selectedLineColor = .white
        text_field.lineHeight = 1.0 // bottom line height in points
        text_field.selectedLineHeight = 2.0
        text_field.errorColor = UIColor(r: 215, g: 0, b: 0)
        text_field.autocapitalizationType = .none
        text_field.isSecureTextEntry = true
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    /* password confirmation field */
    
    let password_confirmation_text_field : SkyFloatingLabelTextFieldWithIcon = {
        let text_field = SkyFloatingLabelTextFieldWithIcon()
        text_field.placeholder = "confirm password"
        text_field.placeholderColor = .white
        text_field.placeholderFont = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.font = UIFont(name: "GothamRounded-Light", size: 18)
        text_field.iconFont = UIFont(name: "FontAwesome", size: 21)
        text_field.iconText = String.fontAwesomeIcon(code: "fa-lock")
        text_field.iconMarginLeft = 8.0
        text_field.iconColor = .white
        text_field.tintColor = .white
        text_field.textColor = .white
        text_field.lineColor = .white
        text_field.selectedIconColor = .white
        text_field.titleColor = .white
        text_field.selectedTitleColor = .white
        text_field.selectedLineColor = .white
        text_field.lineHeight = 1.0 // bottom line height in points
        text_field.selectedLineHeight = 2.0
        text_field.errorColor = UIColor(r: 215, g: 0, b: 0)
        text_field.autocapitalizationType = .none
        text_field.isSecureTextEntry = true
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    /* return to login button */
    
    let return_to_login_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0)
        button.setTitle("Log In", for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(openLoginPage), for: .touchUpInside)
        return button
    }()
    
    /* registration button */
    
    lazy var registration_button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        
        button.addTarget(self, action: #selector(handleRegistration),
                         for: .touchUpInside)
        return button
    }()
    
    
    /* constraints */
    
    func constrainLoginBackgroundImage() {
        login_background_image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        login_background_image.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        login_background_image.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        login_background_image.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func constrainRegistrationTitle() {
        registration_title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registration_title.centerYAnchor.constraint(equalTo: name_text_field.centerYAnchor, constant: -40).isActive = true
        registration_title.widthAnchor.constraint(equalTo: name_text_field.widthAnchor, constant: 15).isActive = true
        registration_title.heightAnchor.constraint(equalTo: name_text_field.heightAnchor, constant: -5).isActive = true
    }
    
    func constrainNameInputField() {
        
        // name field
        name_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        name_text_field.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -5).isActive = true
        name_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -120).isActive = true
        name_text_field.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func constrainEmailInputField() {
        
        // email field
        email_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        email_text_field.centerYAnchor.constraint(equalTo: name_text_field.centerYAnchor, constant: 55).isActive = true
        email_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -120).isActive = true
        email_text_field.heightAnchor.constraint(equalTo: name_text_field.heightAnchor).isActive = true
    }

    func constrainPasswordInputField() {
        
        // password field
        password_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        password_text_field.centerYAnchor.constraint(equalTo: email_text_field.centerYAnchor, constant: 55).isActive = true
        password_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -120).isActive = true
        password_text_field.heightAnchor.constraint(equalTo: email_text_field.heightAnchor).isActive = true
    }
    
    func constrainPasswordConfirmationInputField() {
        
        // password field
        password_confirmation_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        password_confirmation_text_field.centerYAnchor.constraint(equalTo: password_text_field.centerYAnchor, constant: 55).isActive = true
        password_confirmation_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -120).isActive = true
        password_confirmation_text_field.heightAnchor.constraint(equalTo: password_text_field.heightAnchor).isActive = true
        
    }
    
    func constrainRegistrationButton() {
        registration_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registration_button.topAnchor.constraint(equalTo: password_confirmation_text_field.bottomAnchor, constant: 21).isActive = true
        registration_button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        registration_button.heightAnchor.constraint(equalTo: password_confirmation_text_field.heightAnchor, constant: -13).isActive = true
    }
    
    func constrainReturnToLoginButton() {
        return_to_login_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return_to_login_button.topAnchor.constraint(equalTo: registration_button.bottomAnchor, constant: 3).isActive = true
        return_to_login_button.widthAnchor.constraint(equalTo: password_confirmation_text_field.widthAnchor).isActive = true
        return_to_login_button.heightAnchor.constraint(equalTo: password_confirmation_text_field.heightAnchor, constant: -10).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
