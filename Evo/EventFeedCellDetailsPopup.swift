//
//  FeedDetailsView.swift
//  Evo
//
//  Created by Admin on 5/11/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

protocol EventFeedCellDetailsPopupDelegate: PopupViewDelegate {
    func viewEntityPage()
    func getNamesDict(_ event: Event, _ completion: @escaping (Dictionary<String, String>) -> Void)
}

class EventFeedCellDetailsPopup: PopupView {
    
    var event: Event
    
    required init(with event: Event) {
        self.event = event
        
        super.init()
        
        self.load(with: event)
        self.frame = self.estimatePopupViewSize(with: event)
        self.setUpViews()
    }
    
    private func setUpViews() {
        if self.event.state == .ended {
            self.completion_view = SingleOptionPopupCompletionView(self, button_title: "Finished!")
            self.addViews()
        }
        else {
            Event.isAttending(Auth.auth().currentUser!.uid, self.event.id) { is_attending in
                DispatchQueue.main.async {
                    self.completion_view = is_attending ?
                        self.event.accessibility == .invite_only && Auth.auth().currentUser!.uid != self.event.uid ?
                            SingleOptionPopupCompletionView(self, button_title: "Cancel") :
                            DualOptionPopupCompletionView(self, button_title1: "Cancel", button_title2: "Invite")
                        : SingleOptionPopupCompletionView(self, button_title: "Go!")
                    
                    self.addViews()
                }
            }
        }
    }
    
    private func addRemoveButton() {
        self.addSubview(remove_button)
        constrainRemoveButton()
    }
    
    private func addViews() {
        if self.event.posted_by_current_user {
            self.addRemoveButton()
        }
        
        event.isInGroupOwnedByCurrentUser { bool in
            if bool {
                DispatchQueue.main.async {
                    self.addRemoveButton()
                }
            }
        }
        
        self.addSubview(title_text_view)
        self.addSubview(profile_image_view)
        self.addSubview(name_label)
        self.addSubview(tag_label)
        self.addSubview(description_text_view)
        self.addSubview(distance_label)
        self.addSubview(ages_label)
        self.addSubview(time_label)
        self.addSubview(location_button)
        
        constrainTitle()
        constrainProfileImage()
        constrainNameLabel()
        constrainTagLabel()
        constrainDescriptionTextView()
        constrainDistanceLabel()
        constrainAgesLabel()
        constrainLocationButton()
        constrainTimeLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    /// remove button
    lazy var remove_button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "remove_event_button").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeEvent), for: .touchUpInside)
        return button
    }()
    
    /// title
    
    /*
    let title_text_view: UITextView = {
        let text_view = UITextView()
        text_view.font = UIFont(size: 27)
        text_view.textAlignment = .center
        text_view.textColor = .black
        text_view.isUserInteractionEnabled = false
        text_view.isScrollEnabled = false
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()*/
    
    let title_text_view: UILabel = {
        let text_view = UILabel()
        text_view.font = UIFont(size: 27)
        text_view.textAlignment = .center
        text_view.textColor = .black
        text_view.adjustsFontSizeToFitWidth = true
        text_view.numberOfLines = 2
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    /// profile pic
    
    static let size_of_profile_image: CGFloat = 75
    
    lazy var profile_image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.borderColor = UIColor.black.cgColor
        image_view.layer.borderWidth = 1
        image_view.layer.masksToBounds = true
        image_view.layer.cornerRadius = EventFeedCellDetailsPopup.size_of_profile_image / 2.0
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.isUserInteractionEnabled = true
        image_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewEntityPage(gesture_recognizer:))))
        return image_view
    }()
    
    /// name
    
    lazy var name_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewEntityPage(gesture_recognizer:))))
        return label
    }()
    
    /// tag
    
    let tag_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 17)
        label.textColor = .white
        label.backgroundColor = .EVO_blue
        label.textAlignment = .center
        label.layer.cornerRadius = 7
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// description
    
    let description_text_view: UITextView = {
        let text_view = UITextView()
        text_view.font = UIFont(size: 15)
        text_view.textAlignment = .center
        text_view.textColor = .EVO_text_gray
        text_view.textContainerInset = .zero
        text_view.textContainer.lineFragmentPadding = 0
        text_view.translatesAutoresizingMaskIntoConstraints = false
        text_view.isEditable = false
        return text_view
    }()
    
    /// distance
    
    let distance_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// ages
    
    let ages_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// start/end time label
    
    let time_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 17)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// location
    lazy var location_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.titleLabel!.font = UIFont(size: 17)
        button.titleLabel!.adjustsFontSizeToFitWidth = true
        button.titleLabel!.textAlignment = .center
        button.setTitleColor(.EVO_blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(getDirectionsToLocation), for: .touchUpInside)
        return button
    }()
    
    
    /// constraints
    
    func constrainTitle() {
        title_text_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        title_text_view.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        title_text_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -80).isActive = true
        /*
        let text_view_attributes = [NSFontAttributeName: UIFont(size: 27)]
        
        let estimated_text_view_frame = NSString(string: self.event.title).boundingRect(with: CGSize(width: self.frame.size.width - 80, height: 1000), options: .usesLineFragmentOrigin, attributes: text_view_attributes, context: nil)
        
        self.title_text_view.heightAnchor.constraint(equalToConstant: estimated_text_view_frame.height).isActive = true*/
    }
    
    func constrainProfileImage() {
        let y_offset_from_title: CGFloat = 20
        let x_offset_from_left: CGFloat = 30
        
        profile_image_view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: x_offset_from_left).isActive = true
        profile_image_view.topAnchor.constraint(equalTo: title_text_view.bottomAnchor, constant: y_offset_from_title).isActive = true
        profile_image_view.widthAnchor.constraint(equalToConstant: EventFeedCellDetailsPopup.size_of_profile_image).isActive = true
        profile_image_view.heightAnchor.constraint(equalToConstant: EventFeedCellDetailsPopup.size_of_profile_image).isActive = true
    }
    
    func constrainNameLabel() {
        let width_of_name: CGFloat = 150.0
        let y_offset_from_title: CGFloat = 30
        let x_offset_from_right: CGFloat = -30
        
        name_label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: x_offset_from_right).isActive = true
        name_label.topAnchor.constraint(equalTo: title_text_view.bottomAnchor, constant: y_offset_from_title).isActive = true
        name_label.widthAnchor.constraint(equalToConstant: width_of_name).isActive = true
    }
    
    func constrainTagLabel() {
        tag_label.centerXAnchor.constraint(equalTo: name_label.centerXAnchor).isActive = true
        tag_label.topAnchor.constraint(equalTo: name_label.bottomAnchor, constant: 5).isActive = true
        tag_label.widthAnchor.constraint(equalToConstant: tag_label.intrinsicContentSize.width + 20).isActive = true
        tag_label.heightAnchor.constraint(equalToConstant: tag_label.intrinsicContentSize.height + 10).isActive = true
    }
    
    func constrainDescriptionTextView() {
        description_text_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        description_text_view.topAnchor.constraint(equalTo: tag_label.bottomAnchor, constant: 30).isActive = true
        description_text_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        let description_attributes = [NSAttributedStringKey.font: UIFont(size: 15)/*, NSTextAlignment: NSTextAlignment.center*/]
        let estimated_description_frame = NSString(string: event.description).boundingRect(with: CGSize(width: self.frame.width - 20, height: 1000), options: .usesLineFragmentOrigin, attributes: description_attributes, context: nil)
        
        description_text_view.heightAnchor.constraint(equalToConstant: estimated_description_frame.height + 15).isActive = true
    }
    
    func constrainDistanceLabel() {
        distance_label.rightAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        distance_label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        distance_label.topAnchor.constraint(equalTo: description_text_view.bottomAnchor, constant: 10).isActive = true
    }
    
    func constrainAgesLabel() {
        ages_label.leftAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ages_label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        ages_label.topAnchor.constraint(equalTo: description_text_view.bottomAnchor, constant: 10).isActive = true
    }
    
    func constrainLocationButton() {
        location_button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        location_button.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        location_button.bottomAnchor.constraint(equalTo: completion_view.topAnchor, constant: -5).isActive = true
        location_button.heightAnchor.constraint(equalToConstant: location_button.intrinsicContentSize.height).isActive = true
    }
    
    func constrainTimeLabel() {
        time_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        time_label.bottomAnchor.constraint(equalTo: location_button.topAnchor).isActive = true
    }
    
    func constrainRemoveButton() {
        remove_button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        remove_button.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        remove_button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        remove_button.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
}

extension EventFeedCellDetailsPopup {
    
    func attendEvent() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        (self.delegate as? EventFeedCellDetailsPopupDelegate)?.getNamesDict(self.event) { dict in
            if self.event.accessibility != .invite_only {
                self.delegate?.changePopup(to: EventInvitationPopup(dict, self.event))
            }
            else {
                self.delegate?.close()
            }
            Event.attend(uid, self.event.id)
            
            Analytics.logEvent("attend_event_from_go_button", parameters: nil)
        }
    }
    
    func showExpiredMessage() {
        self.viewController()?.showAlert(title: "Sorry, this event has ended.", message: nil, acceptence_text: "Okay", cancel: false, completion: nil)
    }
    
    func cancelEvent() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if uid == self.event.uid {
            self.viewController()?.showAlert(title: "Are you sure you would like to cancel on this event?", message: "Since you were the creator of the event, it will be deleted.", acceptence_text: "Yes", cancel: true) { action in
                Event.remove(self.event.id, self.event.gid)
                self.delegate?.close()
            }
        }
        else {
            self.viewController()?.showAlert(title: "Are you sure you would like to cancel on this event?", message: nil, acceptence_text: "Yes", cancel: true) { action in
                Event.cancelAttendence(uid, self.event.id)
                self.delegate?.close()
            }
        }
    }
    
    func openInvitationPopup() {
        (self.delegate as? EventFeedCellDetailsPopupDelegate)?.getNamesDict(self.event) { dict in
            self.delegate?.changePopup(to: EventInvitationPopup(dict, self.event))
        }
    }
    
}

extension EventFeedCellDetailsPopup: SingleOptionPopupCompletionViewDelegate {
    
    func handleCompletion() {
        if self.event.state == .ended {
            self.showExpiredMessage()
        }
        else {
            Event.isAttending(Auth.auth().currentUser!.uid, self.event.id) { is_attending in
                is_attending ? self.cancelEvent() : self.attendEvent()
            }
        }
    }
    
}

extension EventFeedCellDetailsPopup: DualOptionPopupCompletionViewDelegate {
    
    func handleCompletion1() {
        self.cancelEvent()
    }
    
    func handleCompletion2() {
        self.openInvitationPopup()
    }
    
}
