//
//  ResetPasswordController.swift
//  Evo
//
//  Created by Tommy Nordberg on 4/29/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import FontAwesome_swift

class ResetPasswordController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        view.addSubview(reset_password_background_image)
        view.addSubview(reset_password_title)
        view.addSubview(email_text_field)
        view.addSubview(return_to_login_button)
        view.addSubview(reset_password_button)
        
        constrainResetPasswordTitle()
        constrainResetPasswordBackgroundImage()
        constrainEmailInputField()
        constrainReturnToLoginButton()
        constrainResetPasswordButton()
    }
    
    /* background image */
    
    let reset_password_background_image: UIImageView = {
        let image_view = UIImageView()
        image_view.image = UIImage(named: "login_background")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()

    /* title */
    
    let reset_password_title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 33)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Reset Password"
        return label
    }()
    
    /* email text */
    
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
    
    /* return to login button */
    
    let return_to_login_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0)
        button.setTitle("Log In", for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(dismissToLogin), for: .touchUpInside)
        return button
    }()
    
    
    /* reset password button */
    
    lazy var reset_password_button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        
        button.addTarget(self, action: #selector(handlePasswordReset),
                         for: .touchUpInside)
        return button
    }()
    
    /* constraints */
    
    func constrainResetPasswordBackgroundImage() {
        reset_password_background_image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reset_password_background_image.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        reset_password_background_image.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        reset_password_background_image.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func constrainResetPasswordTitle() {
        reset_password_title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reset_password_title.centerYAnchor.constraint(equalTo: email_text_field.centerYAnchor, constant: -40).isActive = true
        reset_password_title.widthAnchor.constraint(equalTo: email_text_field.widthAnchor, constant: 15).isActive = true
        reset_password_title.heightAnchor.constraint(equalTo: email_text_field.heightAnchor, constant: -5).isActive = true
    }
    
    func constrainEmailInputField() {
        
        // name field
        email_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        email_text_field.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        email_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -120).isActive = true
        email_text_field.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func constrainResetPasswordButton() {
        reset_password_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reset_password_button.topAnchor.constraint(equalTo: email_text_field.bottomAnchor, constant: 21).isActive = true
        reset_password_button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        reset_password_button.heightAnchor.constraint(equalTo: email_text_field.heightAnchor, constant: -13).isActive = true
    }
    
    func constrainReturnToLoginButton() {
        return_to_login_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return_to_login_button.topAnchor.constraint(equalTo: reset_password_button.bottomAnchor, constant: 3).isActive = true
        return_to_login_button.widthAnchor.constraint(equalTo: email_text_field.widthAnchor).isActive = true
        return_to_login_button.heightAnchor.constraint(equalTo: email_text_field.heightAnchor, constant: -10).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
