//
//  ProfileHeader.swift
//  Evo
//
//  Created by Admin on 4/15/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import LBTAComponents

class ProfileHeader: DatasourceCell {
    
    static let height: CGFloat = 140
    var profile: Profile!
    
    override var datasourceItem: Any? {
        didSet {
            guard let profile = datasourceItem as? Profile else { return }
            self.profile = profile
            
            name_label.text = profile.name
            
            self.location_label.text = "Location: \(self.profile.location ?? "N/A")"
            self.age_label.text = "Age: \(self.profile.age.map { String($0) } ?? "N/A")"
            
            if let image_url = self.profile.image_url {
                profile_image_view.kf.setImage(with: URL(string: image_url))
            }
            else {
                profile_image_view.image = #imageLiteral(resourceName: "default_user_image")
            }

            Profile.getNumberOfGroups(forUID: profile.id) { num in
                DispatchQueue.main.async {
                    self.following_view.groups_button.setTitle(String(num), for: .normal)
                }
            }
            
            Profile.getNumberOfFollowers(forUID: profile.id) { num in
                DispatchQueue.main.async {
                    self.following_view.followers_button.setTitle(String(num), for: .normal)
                }
            }
            
            Profile.getNumberOfFollowings(forUID: profile.id) { num in
                DispatchQueue.main.async {
                    self.following_view.following_button.setTitle(String(num), for: .normal)
                }
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        self.separatorLineView.isHidden = false
        self.separatorLineView.backgroundColor = .EVO_border_gray
        
        self.addSubview(self.profile_image_view)
        self.addSubview(self.name_label)
        self.addSubview(self.following_view)
        self.addSubview(self.location_label)
        self.addSubview(self.age_label)
        
        profile_image_view.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 18, bottomConstant: 0, rightConstant: 0, widthConstant: 75, heightConstant: 75)
        
        name_label.topAnchor.constraint(equalTo: profile_image_view.topAnchor, constant: 3).isActive = true
        name_label.leftAnchor.constraint(equalTo: profile_image_view.rightAnchor, constant: 15).isActive = true
        
        following_view.centerYAnchor.constraint(equalTo: separatorLineView.topAnchor, constant: -25).isActive = true
        following_view.leftAnchor.constraint(equalTo: profile_image_view.leftAnchor, constant: -10).isActive = true
        
        self.location_label.leftAnchor.constraint(equalTo: self.name_label.leftAnchor).isActive = true
        self.location_label.topAnchor.constraint(equalTo: self.name_label.bottomAnchor, constant: 6.5).isActive = true
        
        self.age_label.leftAnchor.constraint(equalTo: self.name_label.leftAnchor).isActive = true
        self.age_label.topAnchor.constraint(equalTo: self.location_label.bottomAnchor, constant: 6.5).isActive = true
    }
    
    let following_view = ProfileFollowingView()
    
    let profile_image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.cornerRadius = 75/2
        image_view.layer.masksToBounds = true
        return image_view
    }()
    
    let name_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 23)
        label.textAlignment = .center
        label.textColor = .EVO_text_gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let location_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 15)
        label.textAlignment = .center
        label.textColor = .EVO_text_gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let age_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 15)
        label.textAlignment = .center
        label.textColor = .EVO_text_gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
