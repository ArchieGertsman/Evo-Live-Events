//
//  ProfilePrivateInformationContainerView.swift
//  Evo
//
//  Created by Admin on 6/12/17.
//  Copyright © 2017 Evo. All rights reserved.
//
/*
import UIKit

class ProfilePrivateInformationContainerView: UIView {
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.EVO_border_gray.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // subviews
        
        self.addSubview(email_label)
        self.addSubview(email_text_field)
        self.addSubview(separator1)
        
        self.addSubview(phone_label)
        self.addSubview(phone_text_field)
        self.addSubview(separator2)
        
        self.addSubview(gender_label)
        self.addSubview(gender_text_field)
        self.addSubview(separator3)
        
        // constraints
        
        self.constrainEmailInformation()
        self.constrainPhoneInformation()
        self.constrainGenderInformation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /// email
    
    let email_label: UILabel = {
        let label = UILabel()
        label.text = "Email: "
        label.textColor = .EVO_border_gray
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let email_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .EVO_text_gray
        text_field.autocapitalizationType = .none
        text_field.keyboardType = .emailAddress
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    let separator1: UIView = {
        let view = UIView()
        view.backgroundColor = .EVO_border_gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// phone number
    
    let phone_label: UILabel = {
        let label = UILabel()
        label.text = "Phone: "
        label.textColor = .EVO_border_gray
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let phone_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .EVO_text_gray
        text_field.translatesAutoresizingMaskIntoConstraints = false
        text_field.keyboardType = UIKeyboardType.numberPad
        return text_field
    }()
    let separator2: UIView = {
        let view = UIView()
        view.backgroundColor = .EVO_border_gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// gender
    
    let gender_label: UILabel = {
        let label = UILabel()
        label.text = "Gender: "
        label.textColor = .EVO_border_gray
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var gender_text_field: UITextField = {
        var text_field = UITextField()
        text_field.textColor = .EVO_text_gray
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    let separator3: UIView = {
        let view = UIView()
        view.backgroundColor = .EVO_border_gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    /* constraints */
    
    func constrainEmailInformation() {
        let email_label_width = email_label.intrinsicContentSize.width
        
        // email label
        email_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        email_label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        email_label.widthAnchor.constraint(equalToConstant: email_label_width).isActive = true
        email_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/3).isActive = true
        
        // email field
        email_text_field.leftAnchor.constraint(equalTo: email_label.rightAnchor).isActive = true
        email_text_field.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        email_text_field.topAnchor.constraint(equalTo: email_label.topAnchor).isActive = true
        email_text_field.heightAnchor.constraint(equalTo: email_label.heightAnchor).isActive = true
        
        // separator 1
        separator1.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        separator1.topAnchor.constraint(equalTo: email_text_field.bottomAnchor, constant: -10).isActive = true
        separator1.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        separator1.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    func constrainPhoneInformation() {
        let phone_label_width = phone_label.intrinsicContentSize.width
        
        // phone label
        phone_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        phone_label.topAnchor.constraint(equalTo: separator1.bottomAnchor, constant: 5).isActive = true
        phone_label.widthAnchor.constraint(equalToConstant: phone_label_width).isActive = true
        phone_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/3).isActive = true
        
        // phone field
        phone_text_field.leftAnchor.constraint(equalTo: phone_label.rightAnchor).isActive = true
        phone_text_field.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        phone_text_field.topAnchor.constraint(equalTo: phone_label.topAnchor).isActive = true
        phone_text_field.heightAnchor.constraint(equalTo: phone_label.heightAnchor).isActive = true
        
        // separator 2
        separator2.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        separator2.topAnchor.constraint(equalTo: phone_text_field.bottomAnchor, constant: -10).isActive = true
        separator2.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        separator2.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    func constrainGenderInformation() {
        let gender_label_width = gender_label.intrinsicContentSize.width
        
        // age label
        gender_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        gender_label.topAnchor.constraint(equalTo: separator2.bottomAnchor, constant: 5).isActive = true
        gender_label.widthAnchor.constraint(equalToConstant: gender_label_width).isActive = true
        gender_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/3).isActive = true
        
        // age field
        gender_text_field.leftAnchor.constraint(equalTo: gender_label.rightAnchor).isActive = true
        gender_text_field.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        gender_text_field.topAnchor.constraint(equalTo: gender_label.topAnchor).isActive = true
        gender_text_field.heightAnchor.constraint(equalTo: gender_label.heightAnchor).isActive = true
        
        // separator 3
        separator3.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        separator3.topAnchor.constraint(equalTo: gender_text_field.bottomAnchor, constant: -10).isActive = true
        separator3.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
        separator3.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

}
 */
