//
//  EventFeedCellDetailsController.swift
//  Evo
//
//  Created by Admin on 7/24/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

/* controller than contains the event details popup */
class EventFeedCellDetailsController: PopupController {
    
    internal let event: Event
    internal var names_dict = Dictionary<String, String>()
    override var viewController: UIViewController? {
        didSet {
            self.fillInEntityInformation()
        }
    }
    
    required init(_ event: Event) {
        self.event = event
        super.init(with: EventFeedCellDetailsPopup(with: event))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(with popup: PopupView) {
        fatalError("init(with:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let transparent_color = UIColor(r: 0, g: 0, b: 0, a: 190)
        self.view.backgroundColor = transparent_color
        
        // if a point on the screen that is outside of the popup is tapped then remove this controller
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleClose(gesture_recognizer:)))
        tgr.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tgr)
    }
    
    
}

extension EventFeedCellDetailsController: EventFeedCellDetailsPopupDelegate, EventInvitationPopupDelegate {
    
    func fillInEntityInformation() {
        switch self.event.entity_type {
        case .user: self.tryToFillProfileInformation()
        case .group: self.viewController! is GroupController ?
                self.tryToFillProfileInformation() :
                self.tryToFillGroupInformation()
        }
    }
    
    internal func tryToFillProfileInformation() {
        let event_details_popup = (self.popup as! EventFeedCellDetailsPopup)
        
        if let profile = self.event.profile {
            event_details_popup.fillProfileInformation(with: profile)
        } else {
            Profile.initProfile(with: event.uid) { profile in
                if let profile = profile {
                    // profile successfully loaded
                    event_details_popup.fillProfileInformation(with: profile)
                } else {
                    fatalError("unable to load profile [EventFeedCellDetailsController.fillInEntityInformation]")
                }
            }
        }
    }
    
    internal func tryToFillGroupInformation() {
        let event_details_popup = (self.popup as! EventFeedCellDetailsPopup)
        
        if let group = self.event.group {
            event_details_popup.fillGroupInformation(with: group)
        } else {
            // make sure the event is actually associated with a group
            guard let gid = self.event.gid else { fatalError("no gid [EventFeedCellDetailsController.tryToFilLGroupInformation]") }
            
            Group.initGroup(with: gid) { group in
                if let group = group {
                    // group successfully loaded
                    event_details_popup.fillGroupInformation(with: group)
                } else {
                    fatalError("unable to load group [EventFeedCellDetailsController.tryToFilLGroupInformation]")
                }
            }
        }
    }
    
    // if entity image/name is tapped then view its page
    func viewEntityPage() {
        if let _ = self.viewController as? GroupController {
            /* if the user is on a group's page, each event shoes the individual person that created the event.
             Since the entity in each details view MUST be a person, then view his/her profile */
            self.viewProfile()
        }
        else if let profile_controller = self.viewController as? ProfileController {
            /* if the user is on a profile page, each event will either show the individual or the group that created it.
             If the entity is a person, then view his/her profile. If the entity is a group, then view its page. */
            switch self.event.entity_type {
            case .user: // if already on user's page then close the details view. Otherwise go to the page
                self.event.uid == profile_controller.profile.id ? self.close() : self.viewProfile()
            case .group: self.viewGroup()
            }
        }
        else {
            // the user is on the main feed. Open the entity's page.
            (event.entity_type == .user ? self.viewProfile : self.viewGroup)()
        }
    }
    
    private func viewProfile() {
        if let event_feed_controller = self.viewController as? EventFeedController {
            
            // cycle through stack of controllers to see if this profile is already open
            for controller in event_feed_controller.navigationController!.viewControllers {
                if (controller is ProfileController && (controller as! ProfileController).profile.id == self.event.profile!.id) {
                    self.close()
                    event_feed_controller.navigationController?.popToViewController(controller, animated: true)
                    return
                }
            }
            
            self.close()
            event_feed_controller.navigationController?.pushViewController(ProfileController(of: self.event.profile!), animated: true)
        }
        else if let feed_tab_bar_controller = self.viewController as? MainEventFeedTabBarController {
            self.close()
            feed_tab_bar_controller.navigationController?.pushViewController(ProfileController(of: self.event.profile!), animated: true)
        }
    }
    
    private func viewGroup() {
        if let event_feed_controller = self.viewController as? EventFeedController {
            
            // cycle through stack of controllers to see if this group is already open
            for controller in event_feed_controller.navigationController!.viewControllers {
                if (controller is GroupController && (controller as! GroupController).group.id == self.event.group!.id) {
                    self.close()
                    event_feed_controller.navigationController?.popToViewController(controller, animated: true)
                    return
                }
            }
            
            self.close()
            event_feed_controller.navigationController?.pushViewController(GroupController(of: self.event.group!), animated: true)
        }
        else if let feed_tab_bar_controller = self.viewController as? MainEventFeedTabBarController {
            self.close()
            feed_tab_bar_controller.navigationController?.pushViewController(GroupController(of: self.event.group!), animated: true)
        }
    }
    
    func showEventRemovalAlert(_ eid: String, _ gid: String?, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Are you sure you would like to delete this event?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
            Event.remove(eid, gid)
            self.close()
            completion(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completion(false)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // get a dictionary of users that can be invited to the event
    func getNamesDict(_ event: Event, _ completion: @escaping (UsersDict) -> Void) {
        let ref = Database.database().reference()
        
        ref.child(DBChildren.user_followings).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let following_uids_dict = snapshot.value as? [String : AnyObject] else {
                completion(self.names_dict)
                return
            }
            let following_uids = Array(following_uids_dict.keys) // dict of people that the current user is following
            
            Profile.initProfiles(with: following_uids) { profiles in
                let dispatch_group = DispatchGroup()
                
                // iterate through each profile that the current user is following to determine whether it should be added to the dict
                for profile in profiles {
                    
                    dispatch_group.enter()
                    Event.isAttending(profile.id, event.id) { is_attending in
                        
                        // only add to dict if this user isn't already attending
                        if !is_attending {
                            /* I'm not sure why I added the second part of this condition. What it is saying is to add the event
                             creator to the dict if he/she isn't already attending. Seems rare but I guess it can't hurt to leave it in. */
                            if event.accessibility == .public_ || (event.uid == Auth.auth().currentUser!.uid && event.accessibility != .private_group) {
                                self.addToDict(profile)
                            }
                            else if event.accessibility == .private_group {
                                self.addToDictIfInPrivateGroup(event, profile, dispatch_group)
                            }
                            else {
                                self.addToDictIfInMyCrowds(event.id, profile, dispatch_group)
                            }
                        }
                        
                        dispatch_group.leave()
                    }
                }
                
                dispatch_group.notify(queue: .main) {
                    completion(self.names_dict) // names_dict was modified in the addToDict... functions
                }
            }
        })
    }
    
    private func addToDict(_ profile: Profile) {
        self.names_dict[profile.name] = profile.id
    }
    
    private func addToDictIfInMyCrowds(_ eid: String, _ profile: Profile, _ dispatch_group: DispatchGroup) {
        dispatch_group.enter()
        Event.isInMyCrowds(eid, profile.id) { is_in_my_crowds in
            if is_in_my_crowds {
                self.addToDict(profile)
            }
            dispatch_group.leave()
        }
    }
    
    private func addToDictIfInPrivateGroup(_ event: Event, _ profile: Profile, _ dispatch_group: DispatchGroup) {
        if let gid = event.gid {
            dispatch_group.enter()
            Profile.isInGroup(profile.id, gid) { is_in_group in
                if is_in_group {
                    self.addToDict(profile)
                }
                dispatch_group.leave()
            }
        }
    }
    
}
