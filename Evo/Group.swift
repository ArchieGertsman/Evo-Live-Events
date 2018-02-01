//
//  Group.swift
//  Evo
//
//  Created by Admin on 6/17/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase

struct Group {
    var id: String
    var name: String
    var image_url: String?
    var description: String
    var is_private: Bool
    // var members: Int
    var owner_uid: String
}

extension Group {
    
    static func initGroup(with gid: String, completion: @escaping (_ group: Group?) -> Void) {
        Database.database().reference().child(DBChildren.groups).child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                load(with: dictionary) { group in
                    completion(group)
                }
            }
        })
    }
    
    static func initGroups(with gids: [String], completion: @escaping (_ groups: [Group]) -> Void) {
        let ref = Database.database().reference().child(DBChildren.groups)
        var groups = [Group]()
        let dispatch_group = DispatchGroup()
        
        for gid in gids {
            dispatch_group.enter()
            
            ref.child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                Group.load(with: dictionary) { group in
                    if let group = group {
                        groups.append(group)
                    }
                }
                dispatch_group.leave()
            })
        }
        
        dispatch_group.notify(queue: .main) {
            completion(groups)
        }
    }
    
    static func load(with dictionary: [String: AnyObject], completion: (_ group: Group?) -> Void) {
        
        guard let id = dictionary[DBChildren.Group.id] as? String,
            let name = dictionary[DBChildren.Group.name] as? String,
            let description = dictionary[DBChildren.Group.description] as? String,
            let is_private = dictionary[DBChildren.Group.privacy] as? Bool,
            // let members = dictionary[DBChildren.Group.members] as? Int,
            let owner_uid = dictionary[DBChildren.Group.owner_uid] as? String
            else {
                completion(nil)
                return
        }
        
        let image_url = dictionary[DBChildren.Group.image_url] as? String
        
        let group = Group(id: id, name: name, image_url: image_url, description: description, is_private: is_private, /*members: members, */owner_uid: owner_uid)
        
        completion(group)
    }
    
    static func addMembers(_ uids: [String], _ gid: String) {
        let ref = Database.database().reference()
        
        for uid in uids {
            // let user_profile_ref = users_child_ref.child(uid)
            
            ref.child(DBChildren.user_groups).child(uid).child(gid).setValue(true)
            ref.child(DBChildren.group_members).child(gid).child(uid).setValue(true)
            
            /*
            user_profile_ref.child(DBChildren.groups).runTransactionBlock { current_value -> TransactionResult in
                if let value = current_value.value as? Int {
                    current_value.value = value + 1
                }
                return TransactionResult.success(withValue: current_value)
            }*/
        }
    
        /*
        let group_ref = ref.child(DBChildren.groups).child(gid)
        
        group_ref.child(DBChildren.Group.members).runTransactionBlock { current_value -> TransactionResult in
            if let value = current_value.value as? Int {
                current_value.value = value + uids.count
            }
            return TransactionResult.success(withValue: current_value)
        }*/
    }
    
    static func getMemberIDs(_ gid: String, completion: @escaping ([String]) -> Void) {
        Database.database().reference().child(DBChildren.group_members).child(gid).observeSingleEvent(of: .value, with: { snapshot in
            let uids_dict = snapshot.value as! [String: AnyObject]
            let uids = Array(uids_dict.keys)
            completion(uids)
        })
    }
    
    static func disband(_ gid: String) {
        let ref = Database.database().reference()
        let dispatch_group = DispatchGroup()
        
        // remove each event associated with the group
        dispatch_group.enter()
        ref.child(DBChildren.group_events).child(gid).observeSingleEvent(of: .value, with: { snapshot in
            if let eids_dict = snapshot.value as? [String : AnyObject] {
                dispatch_group.enter()
                Event.getAllEvents(with: Array(eids_dict.keys), query: nil) { events in
                    for event in events {
                        Event.remove(event.id, event.gid)
                    }
                    dispatch_group.leave()
                }
            }
            dispatch_group.leave()
        })
        
        // Have everyone in the group leave the group, then delete the group
        dispatch_group.notify(queue: .main) {
            ref.child(DBChildren.group_members).child(gid).observeSingleEvent(of: .value, with: { snapshot in
                if let uids_dict = snapshot.value as? [String : AnyObject] {
                    for (uid, _) in uids_dict {
                        Profile.leaveGroup(uid, gid)
                    }
                }
                
                ref.child(DBChildren.group_members).child(gid).removeValue()
                ref.child(DBChildren.groups).child(gid).removeValue()
                
                Analytics.logEvent("group_disband", parameters: nil)
            })
        }
    }
    
    static func getNumberOfMembers(forGID gid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.group_members).child(gid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount)
        })
    }
    
    static func isPrivate(_ gid: String, completion: @escaping (Bool) -> Void) {
        Database.database().reference().child(DBChildren.groups).child(gid).observe(.value, with: { snapshot in
            if let group_dict = snapshot.value as? [String: AnyObject] {
                completion(group_dict[DBChildren.Group.privacy] as! Bool)
            }
        })
    }
    
}
