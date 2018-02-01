//
//  LoginController.swift
//  Project
//
//  Created by Admin on 3/12/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import FontAwesome_swift
import CoreLocation

class LoginController: UIViewController {
    
    var controller_id: String?
    var entity_id: String?
    
    convenience init(_ controller_id: String, _ entity_id: String) {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: "Login")
        let background_image_view = UIImageView(image: #imageLiteral(resourceName: "launch_screen_background"))
        background_image_view.frame = self.view.frame
        self.view.addSubview(background_image_view)
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                print("user exists")
                self.handleAuth()
            } else {
                self.setUpUI()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let handle = self.handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func handleAuth() {
        Database.database().reference().child(DBChildren.users).observeSingleEvent(of: .value, with: { snapshot in
            
            // update device token for notifications
            if let token = Messaging.messaging().fcmToken {
                Database.database().reference().child(DBChildren.user_notification_tokens).child(Auth.auth().currentUser!.uid).child(token).setValue(true)
            }
            
            // if the current user's info is only registered into the DB but not firebase then register it
            if let user = Auth.auth().currentUser, user.displayName == nil {
                self.updateUserInfo(user, snapshot)
            }
            
            print("auth launch")
            self.launchApplication()
        })
    }
    
    func launchApplication() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                // location not enabled
                self.navigationController?.pushViewController(LocationEnableMessageController(), animated: true)
            case .authorizedAlways, .authorizedWhenInUse:
                // proceed to feed
                AppDelegate.launchApplication()
            }
        } else {
            // location not enabled
            self.navigationController?.pushViewController(LocationEnableMessageController(), animated: true)
        }
    }
    
    func updateUserInfo(_ user: User, _ snapshot: DataSnapshot) {
        let change_request = user.createProfileChangeRequest()
        guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
        guard let current_user_dict = dictionary[user.uid] as? [String: AnyObject] else { return }
        guard let name = current_user_dict[DBChildren.User.name] as? String else { return }
        change_request.displayName = name
        
        if let image_url = current_user_dict[DBChildren.User.profile_image_url] as? String {
            change_request.photoURL = URL(string: image_url)
        }
        
        change_request.commitChanges { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func setUpUI() {
        view.addSubview(login_background_image)
        view.addSubview(login_title)
        
        view.addSubview(email_text_field)
        view.addSubview(password_text_field)
        view.addSubview(create_account_button)
        view.addSubview(login_button)
        view.addSubview(forgot_password_button)
        
        constrainLoginBackgroundImage()
        constrainEmailField()
        constrainPasswordField()
        constrainCreateAccountButton()
        constrainLoginButton()
        constrainLoginTitle()
        constrainForgotPasswordButton()
    }
    
    /* views */
    
    /// login title
    
    let login_title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 38)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Login"
        return label
    }()
    
    
    /// background image
    
    let login_background_image: UIImageView = {
        let image_view = UIImageView()
        image_view.image = UIImage(named: "login_background")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()
    
    /// email
    
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
    
    /// password
    
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
        text_field.titleColor = .white
        text_field.selectedIconColor = .white
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
    
    /// forgot password button
    
    let forgot_password_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0)
        button.setTitle("Forgot Password", for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(openResetPasswordPage), for: .touchUpInside)
        return button
    }()
    
    /// registration
    
    let create_account_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(openRegistrationPage), for: .touchUpInside)
        return button
    }()
    
    
    /// login button
    
    lazy var login_button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = UIFont(name: "GothamRounded-Medium", size: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        
        button.addTarget(self, action: #selector(handleLogin),
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
    
    func constrainEmailField() {
        email_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        email_text_field.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        email_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        email_text_field.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func constrainPasswordField() {
        password_text_field.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        password_text_field.centerYAnchor.constraint(equalTo: email_text_field.centerYAnchor, constant: 55).isActive = true
        password_text_field.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        password_text_field.heightAnchor.constraint(equalTo: email_text_field.heightAnchor).isActive = true
    }
    
    func constrainCreateAccountButton() {
        create_account_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        create_account_button.topAnchor.constraint(equalTo: login_button.bottomAnchor, constant: 4).isActive = true
        create_account_button.widthAnchor.constraint(equalTo: password_text_field.widthAnchor).isActive = true
        create_account_button.heightAnchor.constraint(equalTo: password_text_field.heightAnchor, constant: -10).isActive = true
    }
    
    func constrainForgotPasswordButton() {
        forgot_password_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgot_password_button.centerYAnchor.constraint(equalTo: create_account_button.centerYAnchor, constant: 27).isActive = true
        forgot_password_button.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -130)
        forgot_password_button.heightAnchor.constraint(equalTo: create_account_button.heightAnchor, constant: -10).isActive = true
        forgot_password_button.widthAnchor.constraint(equalTo: create_account_button.widthAnchor).isActive = true
        
    }
    
    func constrainLoginButton() {
        login_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        login_button.topAnchor.constraint(equalTo: password_text_field.bottomAnchor, constant: 21).isActive = true
        login_button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        login_button.heightAnchor.constraint(equalTo: password_text_field.heightAnchor, constant: -13).isActive = true
    }
    
    func constrainLoginTitle() {
        login_title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        login_title.centerYAnchor.constraint(equalTo: email_text_field.centerYAnchor, constant: -35).isActive = true
        login_title.widthAnchor.constraint(equalTo: email_text_field.widthAnchor).isActive = true
        login_title.heightAnchor.constraint(equalTo: email_text_field.heightAnchor, constant: -5).isActive = true
    }
    
}

