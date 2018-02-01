//
//  PublicGroupHeader.swift
//  Evo
//
//  Created by Admin on 6/18/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Kingfisher
import Firebase

class GroupHeader: DatasourceCell {
    
    static let height: CGFloat = 135
    
    enum ButtonMode {
        case join
        case leave
        case pending
        case disband
    }
    
    var group: Group!
    var membership_button_left_anchor_constraint: NSLayoutConstraint!
    
    override var datasourceItem: Any? {
        didSet {
            guard let group = datasourceItem as? Group else { return }
            self.group = group
            
            if let image_url = group.image_url {
                self.group_image_view.kf.setImage(with: URL(string: image_url))
            } else {
                self.group_image_view.image = #imageLiteral(resourceName: "default_user_image")
                self.group_image_view.backgroundColor = .EVO_blue
            }
            
            self.description_text_view.text = group.description
            
            Group.getNumberOfMembers(forGID: group.id) { num in
                DispatchQueue.main.async {
                    self.members_button.setTitle(String(num), for: .normal)
                }
            }
            
            guard let current_uid = Auth.auth().currentUser?.uid else { return }
            
            Profile.isInGroup(current_uid, group.id) { (in_group) in
                
                if in_group {
                    self.button_mode = (Auth.auth().currentUser!.uid == self.group.owner_uid) ? .disband : .leave
                    return
                }
                
                Profile.isPendingGroup(current_uid, group.id) { is_pending in
                    self.button_mode = is_pending ? .pending : .join
                }
            }
            
        }
    }
    
    var button_mode: ButtonMode = .join {
        didSet {
            self.setHeaderLayout(mode: button_mode)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        self.separatorLineView.isHidden = false
        self.separatorLineView.backgroundColor = .EVO_border_gray
        
        self.addSubview(group_image_view)
        self.addSubview(description_text_view)
        self.addSubview(members_button)
        self.addSubview(members_button_label)
        self.addSubview(membership_button)
        
        self.group_image_view.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 75, heightConstant: 75)
        
        self.membership_button.anchor(nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: 24)
        
        self.description_text_view.topAnchor.constraint(equalTo: self.group_image_view.topAnchor, constant: 5).isActive = true
        self.description_text_view.leftAnchor.constraint(equalTo: self.group_image_view.rightAnchor, constant: 10).isActive = true
        self.description_text_view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        self.description_text_view.bottomAnchor.constraint(equalTo: self.self.group_image_view.bottomAnchor).isActive = true
        
        self.members_button_label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        self.members_button_label.leftAnchor.constraint(equalTo: self.group_image_view.leftAnchor).isActive = true
        
        self.members_button.centerXAnchor.constraint(equalTo: self.members_button_label.centerXAnchor).isActive = true
        self.members_button.bottomAnchor.constraint(equalTo: self.members_button_label.topAnchor, constant: -5).isActive = true
        self.members_button.topAnchor.constraint(equalTo: self.membership_button.topAnchor).isActive = true
        self.members_button.widthAnchor.constraint(equalTo: self.members_button_label.widthAnchor).isActive = true
    }
    
    let group_image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.cornerRadius = 75/2
        image_view.layer.masksToBounds = true
        return image_view
    }()
    
    let description_text_view: UITextView = {
        let text_view = UITextView()
        text_view.textColor = .EVO_text_gray
        text_view.font = UIFont(name: "GothamRounded-Medium", size: 14)
        text_view.isScrollEnabled = false
        text_view.isEditable = false
        text_view.textContainerInset = UIEdgeInsets.zero
        text_view.textContainer.lineFragmentPadding = 0
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    lazy var members_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitleColor(.EVO_text_gray, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 24)
        button.titleEdgeInsets.top = 0.0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openMembersListPage), for: .touchUpInside)
        return button
    }()
    
    
    let members_button_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 12)
        label.textColor = .EVO_text_gray
        label.text = "Members"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var create_event_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "menu_create_button_emblem").withRenderingMode(.alwaysTemplate), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = .EVO_text_gray
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createGroupEvent), for: .touchUpInside)
        return button
    }()
    
    lazy var add_members_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "add_people_emblem").withRenderingMode(.alwaysTemplate), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = .EVO_text_gray
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentAddGroupMembersPopup), for: .touchUpInside)
        return button
    }()
    
    
    lazy var membership_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 14)
        button.setTitleColor(.EVO_blue, for: .normal)
        button.layer.borderColor = UIColor.EVO_blue.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isExclusiveTouch = true
        button.addTarget(self, action: #selector(handleMembership), for: .touchUpInside)
        return button
    }()
    
}
