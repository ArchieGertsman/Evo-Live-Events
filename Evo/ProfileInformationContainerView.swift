//
//  ProfileInformationContainerView.swift
//  Evo
//
//  Created by Admin on 6/12/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

protocol ProfileInformationContainerViewDelegate: class {
    func chooseLocation()
}

class ProfileInformationContainerView: UIView {
    
    var delegate: ProfileInformationContainerViewDelegate?
    static let height: CGFloat = 41.0 * 6 + 20
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.EVO_border_gray.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        for i in 0..<6 {
            let separator = self.separator
            self.addSubview(separator)
            
            separator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            separator.centerYAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(45 + (41 * i))).isActive = true
            separator.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            self.separators.append(separator)
        }
        
        // subviews
        
        self.addSubview(name_label)
        self.addSubview(name_text_field)
        
        self.addSubview(location_label)
        self.addSubview(location_text_display)
        
        self.addSubview(age_label)
        self.addSubview(age_text_field)
        
        self.addSubview(email_label)
        self.addSubview(email_text_field)
        
        self.addSubview(phone_label)
        self.addSubview(phone_text_field)
        
        self.addSubview(gender_label)
        self.addSubview(gender_text_field)
        
        // constraints
        self.constrainNameInformation()
        self.constrainLocationInformation()
        self.constrainAgeInformation()
        self.constrainEmailInformation()
        self.constrainPhoneInformation()
        self.constrainGenderInformation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var separator: UIView {
        let view = UIView()
        view.backgroundColor = .EVO_border_gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    var separators = [UIView]()
    
    /// name
    
    let name_label: UILabel = {
        let label = UILabel()
        label.text = "Name: "
        label.textColor = .EVO_border_gray
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let name_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .EVO_text_gray
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    /// location
    
    let location_label: UILabel = {
        let label = UILabel()
        label.text = "Location: "
        label.textColor = .EVO_border_gray
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var location_text_display: UILabel = {
        let label = UILabel()
        label.textColor = .EVO_text_gray
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.chooseLocation)))
        return label
    }()
    
    @objc func chooseLocation() {
        self.delegate?.chooseLocation()
    }
    
    /// age
    
    let age_label: UILabel = {
        let label = UILabel()
        label.text = "Age: "
        label.textColor = .EVO_border_gray
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var age_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .EVO_text_gray
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
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
        text_field.keyboardType = UIKeyboardType.phonePad
        return text_field
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

    private let test_separator_constant: CGFloat = 7
    
    /* constraints */
    
    func constrainNameInformation() {
        let name_label_width = name_label.intrinsicContentSize.width
        
        // name label
        name_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        name_label.bottomAnchor.constraint(equalTo: self.separators[0].topAnchor, constant: test_separator_constant).isActive = true
        name_label.widthAnchor.constraint(equalToConstant: name_label_width).isActive = true
        name_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/6).isActive = true
        
        // name field
        name_text_field.leftAnchor.constraint(equalTo: name_label.rightAnchor).isActive = true
        name_text_field.rightAnchor.constraint(equalTo: self.separators[0].rightAnchor).isActive = true
        name_text_field.centerYAnchor.constraint(equalTo: name_label.centerYAnchor).isActive = true
        name_text_field.heightAnchor.constraint(equalTo: name_label.heightAnchor).isActive = true
    }
    
    func constrainLocationInformation() {
        let location_label_width = location_label.intrinsicContentSize.width
        
        // location label
        location_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        location_label.bottomAnchor.constraint(equalTo: separators[1].topAnchor, constant: test_separator_constant).isActive = true
        location_label.widthAnchor.constraint(equalToConstant: location_label_width).isActive = true
        location_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/6).isActive = true
        
        // location field
        location_text_display.leftAnchor.constraint(equalTo: location_label.rightAnchor).isActive = true
        location_text_display.rightAnchor.constraint(equalTo: self.separators[1].rightAnchor).isActive = true
        location_text_display.centerYAnchor.constraint(equalTo: location_label.centerYAnchor).isActive = true
        location_text_display.heightAnchor.constraint(equalTo: location_label.heightAnchor).isActive = true
    }
    
    func constrainAgeInformation() {
        let age_label_width = age_label.intrinsicContentSize.width
        
        // age label
        age_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        age_label.bottomAnchor.constraint(equalTo: self.separators[2].topAnchor, constant: test_separator_constant).isActive = true
        age_label.widthAnchor.constraint(equalToConstant: age_label_width).isActive = true
        age_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/6).isActive = true
        
        // age field
        age_text_field.leftAnchor.constraint(equalTo: age_label.rightAnchor).isActive = true
        age_text_field.rightAnchor.constraint(equalTo: self.separators[2].rightAnchor).isActive = true
        age_text_field.centerYAnchor.constraint(equalTo: age_label.centerYAnchor).isActive = true
        age_text_field.heightAnchor.constraint(equalTo: age_label.heightAnchor).isActive = true
    }
    func constrainEmailInformation() {
        let email_label_width = email_label.intrinsicContentSize.width
        
        // email label
        email_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        email_label.bottomAnchor.constraint(equalTo: self.separators[3].topAnchor, constant: test_separator_constant).isActive = true
        email_label.widthAnchor.constraint(equalToConstant: email_label_width).isActive = true
        email_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/6).isActive = true
        
        // email field
        email_text_field.leftAnchor.constraint(equalTo: email_label.rightAnchor).isActive = true
        email_text_field.rightAnchor.constraint(equalTo: self.separators[3].rightAnchor).isActive = true
        email_text_field.centerYAnchor.constraint(equalTo: email_label.centerYAnchor).isActive = true
        email_text_field.heightAnchor.constraint(equalTo: email_label.heightAnchor).isActive = true
    }
    func constrainGenderInformation() {
        let gender_label_width = gender_label.intrinsicContentSize.width
        
        // age label
        gender_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        gender_label.bottomAnchor.constraint(equalTo: self.separators[4].topAnchor, constant: test_separator_constant).isActive = true
        gender_label.widthAnchor.constraint(equalToConstant: gender_label_width).isActive = true
        gender_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/6).isActive = true
        
        // age field
        gender_text_field.leftAnchor.constraint(equalTo: gender_label.rightAnchor).isActive = true
        gender_text_field.rightAnchor.constraint(equalTo: self.separators[4].rightAnchor).isActive = true
        gender_text_field.centerYAnchor.constraint(equalTo: gender_label.centerYAnchor).isActive = true
        gender_text_field.heightAnchor.constraint(equalTo: gender_label.heightAnchor).isActive = true
    }
    func constrainPhoneInformation() {
        let phone_label_width = phone_label.intrinsicContentSize.width
        
        // phone label
        phone_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        phone_label.bottomAnchor.constraint(equalTo: self.separators[5].topAnchor, constant: test_separator_constant).isActive = true
        phone_label.widthAnchor.constraint(equalToConstant: phone_label_width).isActive = true
        phone_label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/6).isActive = true
        
        // phone field
        phone_text_field.leftAnchor.constraint(equalTo: phone_label.rightAnchor).isActive = true
        phone_text_field.rightAnchor.constraint(equalTo: self.separators[5].rightAnchor).isActive = true
        phone_text_field.centerYAnchor.constraint(equalTo: phone_label.centerYAnchor).isActive = true
        phone_text_field.heightAnchor.constraint(equalTo: phone_label.heightAnchor).isActive = true
    }
}
