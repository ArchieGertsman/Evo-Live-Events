//
//  PendingRequest.swift
//  Evo
//
//  Created by Admin on 6/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase

class PendingRequestWrapper {
    let request: PendingRequest
    
    required init(_ request: PendingRequest) {
        self.request = request
    }
}

struct PendingRequest {
    let id: String
    let from_uid: String
    let gid: String
    let timestamp: TimeInterval
    
    let group: Group
    let from_profile: Profile
}

enum PendingRequestMode {
    case incoming
    case sent
}

extension PendingRequest {
    
    static func initPendingRequests(with prids: [String], completion: @escaping (_ pending_request: [PendingRequest]) -> Void) {
        var pending_requests = [PendingRequest]()
        let dispatch_group = DispatchGroup()
        
        for prid in prids {
            
            if let request = Caches.pending_requests.object(forKey: prid as Caches.GroupPendingRequestID) {
                pending_requests.append(request.request)
                continue
            }
            
            dispatch_group.enter()
            load(with: prid)  { pr in
                if let pr = pr {
                    pending_requests.append(pr)
                }
                dispatch_group.leave()
            }
        }
        
        dispatch_group.notify(queue: .main) {
            completion(pending_requests)
        }
    }
    
    static func load(with id: String, completion: @escaping (PendingRequest?) -> Void) {
        Database.database().reference().child(DBChildren.pending_requests).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            load(with: snapshot.value as! [String: AnyObject], completion: { (pr) in
                completion(pr)
            })
        })
    }
    
    // load pending request given requesting user id and group id
    static func getKey(with uid: String, gid: String, completion: @escaping (String?) -> Void) {
        Database.database().reference().child(DBChildren.pending_requests).queryOrdered(byChild: DBChildren.PendingRequest.from_uid).queryEqual(toValue: uid).observeSingleEvent(of: .value) { snapshot in
            let requests_dict = snapshot.value as! [String: AnyObject]
            let request_keys = Array(requests_dict.keys)
            
            for key in request_keys {
                if (requests_dict[key]![DBChildren.PendingRequest.gid])! as! String == gid {
                    completion(key)
                }
            }
        }
    }
    
    private static func load(with dictionary: [String: AnyObject], completion: @escaping (PendingRequest?) -> Void) {
        
        guard let from_uid = dictionary[DBChildren.PendingRequest.from_uid] as? String,
            let gid = dictionary[DBChildren.PendingRequest.gid] as? String
            else {
                completion(nil)
                return
        }
        
        var pending_request: PendingRequest!
        let dispatch_group = DispatchGroup()
        
        dispatch_group.enter()
        Profile.initProfile(with: from_uid) { profile in
            dispatch_group.enter()
            Group.initGroup(with: gid) { group in
                guard let id = dictionary[DBChildren.PendingRequest.id] as? String,
                    let timestamp = dictionary[DBChildren.PendingRequest.timestamp] as? TimeInterval,
                    let profile = profile,
                    let group = group
                    else {
                        completion(nil)
                        return
                }
                
                pending_request = PendingRequest(id: id, from_uid: from_uid, gid: gid, timestamp: timestamp, group: group, from_profile: profile)
                dispatch_group.leave()
            }
            dispatch_group.leave()
        }
    
        dispatch_group.notify(queue: .main) {
            Caches.pending_requests.setObject(PendingRequestWrapper(pending_request), forKey: pending_request.id as Caches.GroupPendingRequestID)
            completion(pending_request)
        }
    }
    
    static func remove(_ id: String) {
        let ref = Database.database().reference()
        
        // load pending request to fetch places where it needs to be removed
        load(with: id) { pr in
            guard let pr = pr else { return }
            
            // remove from requester
            ref.child(DBChildren.user_pending_requests).child(pr.from_uid).child(id).removeValue()
            
            // remove from requestee
            ref.child(DBChildren.pending_requests_for_users).child(pr.group.owner_uid).child(id).removeValue()
            
            // remove object
            ref.child(DBChildren.pending_requests).child(id).removeValue()
        }
    }
    
    static func getNumberOfRequests(forUID uid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.pending_requests_for_users).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            let num = snapshot.childrenCount
            print("numchildren: \(num)")
            completion(num)
        })
    }
    
}
