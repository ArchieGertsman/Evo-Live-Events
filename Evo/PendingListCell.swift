//
//  PendingListCell.swift
//  Evo
//
//  Created by Admin on 6/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

class PendingListCell: DatasourceCell {
    
    var pending_request: PendingRequest!
    
    override var datasourceItem: Any? {
        didSet {
            guard let pending_request = datasourceItem as? PendingRequest else { return }
            self.pending_request = pending_request
            
            if let image_url = self.pending_request.from_profile.image_url {
                self.image_view.kf.setImage(with: URL(string: image_url))
            }
            else {
                self.image_view.image = #imageLiteral(resourceName: "default_user_image")
            }
            
            self.user_name_label.text = pending_request.from_profile.name
            self.group_name_label.text = pending_request.group.name
            
        }
    }
    
    override func setupViews() {
        super.setupViews()
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = .EVO_border_gray
        
        self.addSubview(image_view)
        self.addSubview(user_name_label)
        self.addSubview(info_label)
        self.addSubview(group_name_label)
        self.addSubview(accept_button)
        self.addSubview(decline_button)
        
        image_view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        image_view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        image_view.widthAnchor.constraint(equalToConstant: ProfileListCell.size_of_profile_image).isActive = true
        image_view.heightAnchor.constraint(equalToConstant: ProfileListCell.size_of_profile_image).isActive = true
        
        info_label.centerYAnchor.constraint(equalTo: image_view.centerYAnchor).isActive = true
        info_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        user_name_label.bottomAnchor.constraint(equalTo: info_label.topAnchor, constant: -8).isActive = true
        user_name_label.centerXAnchor.constraint(equalTo: info_label.centerXAnchor).isActive = true
        
        group_name_label.topAnchor.constraint(equalTo: info_label.bottomAnchor, constant: 8).isActive = true
        group_name_label.centerXAnchor.constraint(equalTo: info_label.centerXAnchor).isActive = true
        
        accept_button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        accept_button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        accept_button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        accept_button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        decline_button.rightAnchor.constraint(equalTo: accept_button.leftAnchor, constant: -15).isActive = true
        decline_button.centerYAnchor.constraint(equalTo: accept_button.centerYAnchor).isActive = true
        decline_button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        decline_button.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    /* views */
    
    static let size_of_profile_image: CGFloat = 65
    
    lazy var image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.borderColor = UIColor.black.cgColor
        image_view.layer.borderWidth = 1
        image_view.layer.masksToBounds = true
        image_view.layer.cornerRadius = PendingListCell.size_of_profile_image / 2.0
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.isUserInteractionEnabled = true
        image_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewUserPage(gesture_recognizer:))))
        return image_view
    }()
    
    lazy var user_name_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)
        label.textColor = .EVO_blue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewUserPage(gesture_recognizer:))))
        return label
    }()
    
    let info_label: UILabel = {
        let label = UILabel()
        label.text = "would like to join"
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)
        label.textColor = .EVO_text_gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var group_name_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)
        label.textColor = .EVO_blue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewGroupPage(gesture_recognizer:))))
        return label
    }()
    
    lazy var accept_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "blue_check").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(acceptPendingRequest), for: .touchUpInside)
        return button
    }()
    
    lazy var decline_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "red_cross").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(declinePendingRequest), for: .touchUpInside)
        return button
    }()
    
    @objc func viewUserPage(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            self.controller?.navigationController?.pushViewController(ProfileController(of: self.pending_request.from_profile), animated: true)
        }
    }
    
    @objc func viewGroupPage(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            self.controller?.navigationController?.pushViewController(GroupController(of: self.pending_request.group), animated: true)
        }
    }
    
    @objc func acceptPendingRequest() {
        Profile.joinGroup(self.pending_request.from_profile.id, self.pending_request.group.id)
        PendingRequest.remove(self.pending_request.id)
        
        guard let navigation_controller = (self.controller as? PendingListController)?.navigationController else { return }
        navigation_controller.pushViewController(GroupController(of: self.pending_request.group), animated: true)
    }
    
    @objc func declinePendingRequest() {
        PendingRequest.remove(self.pending_request.id)
    }
    
}
