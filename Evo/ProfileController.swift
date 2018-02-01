//
//  ProfileController.swift
//  Evo
//
//  Created by Admin on 3/19/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

/* displays a user's profile */
class ProfileController: EntityController {
    
    // current user has access to different features on his/her own profile than the profiles of others
    enum ProfileType {
        case current_user
        case other_user
    }

    // the following two variables are stored in the datasource but here is some quick access
    
    internal var profile: Profile {
        get {
            return (self.datasource as! ProfileDatasource).profile
        }
        set {
            (self.datasource as! ProfileDatasource).profile = newValue
        }
    }
    
    internal var profile_type: ProfileType {
        return (self.datasource as! ProfileDatasource).profile_type
    }
    
    required init(of profile: Profile) {
        super.init()
        self.datasource = ProfileDatasource(profile, (profile.id == Auth.auth().currentUser!.uid) ?
            .current_user : .other_user)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(time_mode: Time.Mode) {
        fatalError("init(time_mode:) has not been implemented")
    }
    
    // determines whether a given event should be added to this profile page based on criteria
    override func shouldAdd(_ event: Event, completion: @escaping (Bool) -> Void) -> Void {
        
        // don't add if it is already in datasource
        if ((self.datasource as! ProfileDatasource).sorted_events.contains { $0.id == event.id }) {
            completion(false)
        }
        
        // if the current user is looking at his/her own profile, or at his/her own event, or the event is public in general, then add it
        if self.profile_type == .current_user || event.uid == Auth.auth().currentUser!.uid || event.accessibility == .public_ {
            completion(true)
        }
        else {
            Event.isAttending(Auth.auth().currentUser!.uid, event.id) { is_attending in
                // if the current user is attending the event at question, then add it
                if is_attending {
                    completion(true)
                }
                else {
                    // if the current user has any sort of access to the event then add it
                    Event.isInMyCrowds(event.id, Auth.auth().currentUser!.uid) { is_in_my_crowds in
                        completion(is_in_my_crowds)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initEvoStyle(title: self.profile_type == .current_user ? "My Profile" : self.profile.name)
        
        // set database references to this profile and to this user's events
        let ref = Database.database().reference()
        self.entity_ref = ref.child(DBChildren.users).child(self.profile.id)
        self.event_ids_ref = ref.child(DBChildren.user_events).child(self.profile.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.observeProfile()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
