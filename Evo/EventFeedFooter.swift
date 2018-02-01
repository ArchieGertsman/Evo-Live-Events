//
//  FeedEventFooter.swift
//  Evo
//
//  Created by Admin on 5/20/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

enum FooterType {
    case main
    case profile
    case group
}

struct EventFeedFooterData {
    var event_feed_type: FooterType
    var is_private: Bool
    var is_feed_empty: Bool
    var is_current_user_in_group: Bool?
}

class EventFeedFooter: EvoFooter {
    
    static let normal_height: CGFloat = 80
    static let small_private_height: CGFloat = 150
    static let large_private_height: CGFloat = 210
    static let small_lock_size = CGSize(width: 30, height: 39)
    static let large_lock_size = CGSize(width: 60, height: 78)
    
    override var datasourceItem: Any? {
        didSet {
            guard let footer_data = datasourceItem as? EventFeedFooterData else { return }
            
            // if private group
            if let is_current_user_in_group = footer_data.is_current_user_in_group, footer_data.is_private {
                
                // if current user is in private group then add message label if appropriate and add small private lock
                if is_current_user_in_group {
                    
                    footer_data.is_feed_empty ?
                        self.addMessageLabel(forFeedType: footer_data.event_feed_type)
                        : self.removeMessageLabel()
                    
                    self.addPrivateLock(size: EventFeedFooter.small_lock_size, fontSize: 12)
                }
                else { // else add only a large private lock
                    self.addPrivateLock(size: EventFeedFooter.large_lock_size, fontSize: 24)
                }
            }
            else { // else add message label if appropriate
                footer_data.is_feed_empty ?
                    self.addMessageLabel(forFeedType: footer_data.event_feed_type)
                    : self.removeMessageLabel()
            }
        }
    }
    
    private func addMessageLabel(forFeedType event_feed_type: FooterType) {
        switch event_feed_type {
        case .main: self.addMainEventFeedMessage()
        case .profile: self.addProfileFeedMessage()
        case .group: self.addGroupFeedMessage()
        }
    }
    
    private func addMainEventFeedMessage() {
        self.addMessageLabel(withText: "There are no events currently in your area. Change that by hosting an event!")
    }
    
    private func addProfileFeedMessage() {
        self.addMessageLabel(withText: "This user has not yet attended an event")
    }
    
    private func addGroupFeedMessage() {
        self.addMessageLabel(withText: "No events have been posted to the group")
    }
    
    func addPrivateLock(size: CGSize, fontSize: CGFloat) {
        
        private_lock_label.font = UIFont(name: "OpenSans", size: fontSize)
        
        self.addSubview(private_lock_image_view)
        self.addSubview(private_lock_label)
        
        if let message_label = self.message_label {
            private_lock_image_view.topAnchor.constraint(equalTo: message_label.bottomAnchor, constant: 10).isActive = true
        }
        else {
            private_lock_image_view.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        }
        
        //lock icon
        private_lock_image_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        private_lock_image_view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        private_lock_image_view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        //lock label
        private_lock_label.centerXAnchor.constraint(equalTo: private_lock_image_view.centerXAnchor).isActive = true
        private_lock_label.topAnchor.constraint(equalTo: private_lock_image_view.bottomAnchor, constant: 5).isActive = true
    }
    
    func removeItems() {
        private_lock_image_view.removeFromSuperview()
        private_lock_image_view.removeConstraints(private_lock_image_view.constraints)
        
        private_lock_label.removeFromSuperview()
        private_lock_label.removeConstraints(private_lock_label.constraints)
        // self.removeConstraints(self.constraints)
    }
    
    let private_lock_image_view: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "private_group_emblem")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let private_lock_label: UILabel = {
        let label = UILabel()
        label.textColor = .EVO_text_gray
        label.text = "This Group is Private"
        label.font = UIFont(name: "OpenSans", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}
