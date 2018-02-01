//
//  ProfileListCell.swift
//  Evo
//
//  Created by Admin on 7/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

class ProfileListCell: DatasourceCell {
    
    var profile: Profile!
    
    enum FollowingButtonMode {
        case follow
        case unfollow
    }
    
    var following_button_mode: FollowingButtonMode! {
        didSet {
            self.setFollowButtonAppearence()
        }
    }
    
    override var datasourceItem: Any? {
        didSet {
            self.fillInViews()
        }
    }
    
    internal func fillInViews() {
        guard let profile = datasourceItem as? Profile else { return }
        self.profile = profile
        
        if let image_url = self.profile.image_url {
            self.image_view.kf.setImage(with: URL(string: image_url))
        }
        else {
            self.image_view.image = #imageLiteral(resourceName: "default_user_image")
        }
        
        self.name_label.text = profile.name
        
        if self.profile.id != Auth.auth().currentUser!.uid {
            self.addFollowButton()
        }
        else {
            self.follow_button?.removeFromSuperview()
        }
    }
    
    private static let width_of_follow_button: CGFloat = 80.0
    
    private func addFollowButton() {
        guard let follow_button = self.follow_button else { return }
        self.addSubview(follow_button)
        
        follow_button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        follow_button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        follow_button.widthAnchor.constraint(equalToConstant: ProfileListCell.width_of_follow_button).isActive = true
        follow_button.heightAnchor.constraint(equalToConstant: follow_button.intrinsicContentSize.height).isActive = true
        
        self.showFollowButton()
    }
    
    func showFollowButton() {
        Profile.isFollowing(Auth.auth().currentUser!.uid, self.profile.id) { is_following in
            DispatchQueue.main.async {
                self.following_button_mode = is_following ? .unfollow : .follow
            }
        }
        
    }
    
    private func setFollowButtonAppearence() {
        guard let follow_button = self.follow_button else { return }
        
        switch self.following_button_mode! {
        case .unfollow:
            follow_button.backgroundColor = .white
            follow_button.setTitleColor(.EVO_blue, for: .normal)
            follow_button.setTitle("Unfollow", for: .normal)
        case .follow:
            follow_button.backgroundColor = .EVO_blue
            follow_button.setTitleColor(.white, for: .normal)
            follow_button.setTitle("Follow", for: .normal)
        }
        
        follow_button.layer.borderColor = UIColor.EVO_blue.cgColor
    }
    
    override func setupViews() {
        super.setupViews()
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = .EVO_border_gray
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewProfilePage(gesture_recognizer:))))
        
        self.addSubview(image_view)
        self.addSubview(name_label)
        
        image_view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        image_view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        image_view.widthAnchor.constraint(equalToConstant: ProfileListCell.size_of_profile_image).isActive = true
        image_view.heightAnchor.constraint(equalToConstant: ProfileListCell.size_of_profile_image).isActive = true
        
        name_label.leftAnchor.constraint(equalTo: image_view.rightAnchor, constant: 10).isActive = true
        name_label.centerYAnchor.constraint(equalTo: image_view.centerYAnchor).isActive = true
        name_label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -ProfileListCell.width_of_follow_button - 20).isActive = true
    }
    
    /* views */
    
    static let size_of_profile_image: CGFloat = 65
    
    lazy var image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.borderColor = UIColor.black.cgColor
        image_view.layer.borderWidth = 1
        image_view.layer.masksToBounds = true
        image_view.layer.cornerRadius = ProfileListCell.size_of_profile_image / 2.0
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.isUserInteractionEnabled = true
        return image_view
    }()
    
    let name_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        label.textColor = .EVO_text_gray
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var follow_button: UIButton? = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 16)
        button.layer.borderColor = UIColor.EVO_blue.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return button
    }()
    
    @objc func viewProfilePage(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            
            for controller in self.controller!.navigationController!.viewControllers as Array {
                
                if controller is ProfileController && (controller as! ProfileController).profile.id == profile.id {
                    self.controller!.navigationController!.popToViewController(controller, animated: true)
                    return
                }
            }
            
            (self.controller! as! EntityListController).navigationController?.pushViewController(ProfileController(of: profile), animated: true)
        }
    }
    
    override func prepareForReuse() {
        self.follow_button?.removeFromSuperview()
    }
    
    @objc func handleFollow() {
        let current_uid = Auth.auth().currentUser!.uid
        
        Profile.isFollowing(current_uid, self.profile.id) { is_following in
            is_following ? Profile.unfollow(current_uid, self.profile.id) :
                Profile.follow(current_uid, self.profile.id)
            
            DispatchQueue.main.async {
                self.following_button_mode = is_following ? .follow : .unfollow
            }
        }
    }
    
}
