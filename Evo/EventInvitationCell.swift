//
//  EventInvitationCell.swift
//  Evo
//
//  Created by Admin on 8/2/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

class EventInvitationCell: DatasourceCell {
    
    var invitation: EventInvitation!
    
    override var datasourceItem: Any? {
        didSet {
            guard let invitation = datasourceItem as? EventInvitation else { return }
            self.invitation = invitation
            
            if let image_url = self.invitation.from_profile.image_url {
                self.image_view.kf.setImage(with: URL(string: image_url))
            }
            else {
                self.image_view.image = #imageLiteral(resourceName: "default_user_image")
            }
            
            self.user_name_label.text = invitation.from_profile.name
            self.event_title_label.text = invitation.event.title
        }
    }
    
    override func setupViews() {
        super.setupViews()
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = .EVO_border_gray
        
        self.addSubview(image_view)
        self.addSubview(user_name_label)
        self.addSubview(info_label)
        self.addSubview(event_title_label)
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
        
        event_title_label.topAnchor.constraint(equalTo: info_label.bottomAnchor, constant: 8).isActive = true
        event_title_label.centerXAnchor.constraint(equalTo: info_label.centerXAnchor).isActive = true
        
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
        image_view.layer.cornerRadius = EventInvitationCell.size_of_profile_image / 2.0
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
        label.text = "has invited you to"
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)
        label.textColor = .EVO_text_gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var event_title_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)
        label.textColor = .EVO_blue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewEventDetails(gesture_recognizer:))))
        return label
    }()
    
    lazy var accept_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "blue_check").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.acceptInvitation), for: .touchUpInside)
        return button
    }()
    
    lazy var decline_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "red_cross").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.declineInvitation), for: .touchUpInside)
        return button
    }()
    
    @objc func viewUserPage(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            self.controller?.navigationController?.pushViewController(ProfileController(of: self.invitation.from_profile), animated: true)
        }
    }
    
    @objc func viewEventDetails(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            let popup_controller = EventFeedCellDetailsController(self.invitation.event)
            
            popup_controller.modalPresentationStyle = .overCurrentContext
            popup_controller.modalTransitionStyle = .crossDissolve
            popup_controller.viewController = self.controller
            
            self.controller?.present(popup_controller, animated: true, completion: nil)
        }
    }
    
    @objc func declineInvitation() {
        Event.removeInvitation(self.invitation)
        Analytics.logEvent("decline_event_invitation", parameters: nil)
        self.controller?.navigationController?.popViewController(animated: true)
    }
    
    @objc func acceptInvitation() {
        Event.attend(self.invitation.to_uid, self.invitation.eid)
        Event.removeInvitation(self.invitation)
        Analytics.logEvent("attend_event_from_invitation", parameters: nil)
        openProfileController()
    }
    
    func openProfileController() {
        guard let nc = self.controller?.navigationController else { return }
        
        for controller in nc.viewControllers as Array {
            if controller.isKind(of: ProfileController.self) && (controller as! ProfileController).profile_type == .current_user {
                nc.popToViewController(controller, animated: true)
                return
            }
        }
        
        guard let current_uid = Auth.auth().currentUser?.uid else { return }
        Profile.initProfile(with: current_uid) { profile in
            if let profile = profile {
                nc.pushViewController(ProfileController(of: profile), animated: true)
            }
        }
    }
    
}
