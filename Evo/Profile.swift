//
//  Profile.swift
//  Evo
//
//  Created by Admin on 4/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

class ProfileWrapper {
    let profile: Profile
    
    required init(_ profile: Profile) {
        self.profile = profile
    }
}

struct Profile {
    var id: String
    var name: String
    var image_url: String?
    var email: String
    var location: String?
    var age: UInt?
    var phone: String?
    var gender: String?
}

extension Profile {
    
    static func initProfile(with uid: String, completion: @escaping (Profile?) -> Void) {
        
        Database.database().reference().child(DBChildren.users).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                load(with: dictionary) { profile in
                    completion(profile)
                }
            }
        })
    }
    
    static func initProfiles(with uids: [String], completion: @escaping (_ profiles: [Profile]) -> Void) {
        let ref = Database.database().reference().child(DBChildren.users)
        var profiles = [Profile]()
        let dispatch_group = DispatchGroup()
        
        for uid in uids {
            
            dispatch_group.enter()
            
            ref.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                Profile.load(with: dictionary) { profile in
                    if let profile = profile {
                        profiles.append(profile)
                    }
                }
                dispatch_group.leave()
            })
        }
        
        dispatch_group.notify(queue: DispatchQueue.main, execute: {
            completion(profiles)
        })
    }
    
    static func load(with dictionary: [String: AnyObject], completion: (Profile?) -> Void) {
        guard let id = dictionary[DBChildren.User.id] as? String,
            let name = dictionary[DBChildren.User.name] as? String,
            let email = dictionary[DBChildren.User.email] as? String
        else {
            completion(nil)
            return
        }
        
        let image_url = dictionary[DBChildren.User.profile_image_url] as? String
        let location = dictionary[DBChildren.User.location] as? String
        let age = dictionary[DBChildren.User.age] as? UInt
        let phone = dictionary[DBChildren.User.phone] as? String
        let gender = dictionary[DBChildren.User.gender] as? String
        
        let profile = Profile(id: id, name: name, image_url: image_url, email: email, location: location, age: age, phone: phone, gender: gender)

        completion(profile)
    }
    
    static func isFollowing(_ uid1: String, _ uid2: String, completion: @escaping (_ following: Bool) -> Void) {
        Database.database().reference().child(DBChildren.user_followings).child(uid1).child(uid2).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? Bool {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func isInGroup(_ uid: String, _ gid: String, completion: @escaping (_ in_group: Bool) -> Void) {
        Database.database().reference().child(DBChildren.user_groups).child(uid).child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? Bool {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func follow(_ from_uid: String, _ to_uid: String) {
        let ref = Database.database().reference()
        
        // add target user to current user's following list and add current user to targeted user's followers list
        ref.child(DBChildren.user_followings).child(from_uid).child(to_uid).setValue(true)
        ref.child(DBChildren.user_followers).child(to_uid).child(from_uid).setValue(true)
        
        // add current events of user to my crowds
        ref.child(DBChildren.user_events).child(to_uid).observeSingleEvent(of: .value, with: { snapshot in
            if let event_ids_dict = snapshot.value as? [String: AnyObject] {
                let current_events_query = ref.child(DBChildren.events).queryOrdered(byChild: DBChildren.Event.end_time).queryStarting(atValue: Date().timeIntervalSince1970)
                Event.getAllEvents(with: Array(event_ids_dict.keys), query: current_events_query) { events in
                    for event in events {
                        if event.accessibility == .public_ {
                            Event.addToMyCrowds(event.id, from_uid)
                        }
                        else if event.accessibility == .private_group {
                            Profile.isInGroup(from_uid, event.gid!) { is_in_group in
                                if is_in_group {
                                    Event.addToMyCrowds(event.id, from_uid)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    static func unfollow(_ from_uid: String, _ to_uid: String) {
        let ref = Database.database().reference()
        
        ref.child(DBChildren.user_followings).child(from_uid).child(to_uid).removeValue()
        ref.child(DBChildren.user_followers).child(to_uid).child(from_uid).removeValue()
        
        // remove events of user from my crowds
        ref.child(DBChildren.user_my_crowds_events).child(from_uid).observeSingleEvent(of: .value, with: { snapshot in
            if let event_ids_dict = snapshot.value as? [String: AnyObject] {
                let events_of_unfollowed_user_query = ref.child(DBChildren.events).queryOrdered(byChild: DBChildren.Event.uid).queryEqual(toValue: to_uid)
                Event.getAllEvents(with: Array(event_ids_dict.keys), query: events_of_unfollowed_user_query) { events in
                    for event in events {
                        ref.child(DBChildren.user_my_crowds_events).child(from_uid).child(event.id).removeValue()
                    }
                }
            }
        })
    }
    
    static func getFollowersUIDs(_ uid: String, completion: @escaping ([String]) -> Void) {
        Database.database().reference().child(DBChildren.user_followers).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let uids_dict = snapshot.value as? [String: AnyObject] {
                completion(Array(uids_dict.keys))
            }
            else {
                completion([String]())
            }
        })
    }
    
    static func isPendingGroup(_ uid: String, _ gid: String, completion: @escaping (Bool) -> Void) {
        Database.database().reference().child(DBChildren.pending_requests).queryOrdered(byChild: DBChildren.PendingRequest.from_uid).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snapshot in
        
            if let pending_request_dict = snapshot.value as? [String : AnyObject] {
                for prid in pending_request_dict.keys {
                    if let request_gid = pending_request_dict[prid]![DBChildren.PendingRequest.gid] as? String {
                        completion(request_gid == gid)
                    }
                }
            }
            else {
                completion(false)
            }
            
        })
    }
    
    static func joinGroup(_ uid: String, _ gid: String) {
        Group.addMembers([uid], gid)
    }
    
    static func sendPendingRequest(from uid: String, to group: Group) {
        let ref = Database.database().reference()
        let prid = ref.child(DBChildren.pending_requests).childByAutoId().key
        
        let pending_request = [
            DBChildren.PendingRequest.id: prid,
            DBChildren.PendingRequest.gid: group.id,
            DBChildren.PendingRequest.from_uid: uid,
            DBChildren.PendingRequest.timestamp: Date().timeIntervalSince1970
        ] as [String : Any]
        
        
        let child_updates = [ "/\(DBChildren.pending_requests)/\(prid)": pending_request]
        
        ref.updateChildValues(child_updates)
        
        ref.child(DBChildren.pending_requests_for_users).child(group.owner_uid).child(prid).setValue(true)
        ref.child(DBChildren.user_pending_requests).child(uid).child(prid).setValue(true)
    }
    
    static func leaveGroup(_ uid: String, _ gid: String) {
        let ref = Database.database().reference()
        
        ref.child(DBChildren.user_groups).child(uid).child(gid).removeValue()
        ref.child(DBChildren.group_members).child(gid).child(uid).removeValue()
    }
    
    static func getNumberOfFollowers(forUID uid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.user_followers).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount)
        })
    }
    
    static func getNumberOfFollowings(forUID uid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.user_followings).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount)
        })
    }
    
    static func getNumberOfGroups(forUID uid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.user_groups).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount)
        })
    }
}
