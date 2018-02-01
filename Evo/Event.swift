//
//  Event.swift
//  Evo
//
//  Created by Admin on 4/14/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

class Event {
    
    // TODO: add RawEvent struct and save raw data from DB in such an object within this Event class
    
    enum EntityType {
        case user
        case group
    }
    
    enum State {
        case upcoming
        case live
        case ended
    }
    
    enum Accessibility: String {
        case public_ = "public"
        case my_crowds = "my-crowds"
        case invite_only = "invite-only"
        case private_group = "private-group"
    }
    
    required init(_ title: String, _ description: String, _ tag: Tag, _ ages: AgeRange, _ eid: String, _ uid: String, _ gid: String?, _ cell_background_name: String, _ time: Time, _ accessibility: String) {
        self.title = title
        self.description = description
        self.tag = tag
        self.ages = ages
        self.id = eid
        self.uid = uid
        self.gid = gid
        // self.going = going
        self.cell_background_name = cell_background_name
        self.time = time
        self.accessibility = Accessibility(rawValue: accessibility)!
    }
    
    // firebase node
    var title: String
    var description: String
    var tag: Tag
    var ages: AgeRange
    var id: String        // event ID
    var uid: String        // user ID (from users node)
    var gid: String?        // group ID
    // var going: Int
    var cell_background_name: String
    var accessibility: Accessibility
    
    // custom objects
    var profile: Profile?       // loaded using "uid"
    var group: Group?           // loaded using "gid"
    var time: Time             // loaded using "starttime" and "endtime"
    var place: GMSPlace?
    
    var distance_from_me: Double? {
        
        guard let place = self.place else {
            print("place")
            return nil }
        
        guard let your_location = MapController.current_location else {
            print("no location")
            return nil }
        
        let cl_location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let distance_in_meters = your_location.distance(from: cl_location)
        let miles_in_a_km = 0.000621371
        let distance_in_miles = miles_in_a_km * distance_in_meters
        let distance_rounded = Double(round(distance_in_miles * 10) / 10)
        
        return distance_rounded
    }
    
    var state: State {
        let current_date = Date()
        
        if current_date.compare(self.time.start) == .orderedAscending {
            return .upcoming
        }
        else if current_date.compare(self.time.end) == .orderedDescending {
            return .ended
        }
        else {
            return .live
        }
    }
    
    var entity_type: EntityType {
        return (self.gid == nil) ? .user : .group
    }
    
    var posted_by_current_user: Bool {
        guard let current_uid = Auth.auth().currentUser?.uid else { return false }
        return current_uid == self.uid
    }
    
    func isInGroupOwnedByCurrentUser(completion: @escaping (Bool) -> Void) {
        guard let gid = self.gid else { completion(false); return }
        
        if let group = self.group {
            completion(group.owner_uid == Auth.auth().currentUser!.uid)
        }
        else {
            Group.initGroup(with: gid) { group in
                self.group = group
                completion((group?.owner_uid ?? "") == Auth.auth().currentUser!.uid)
            }
        }
    }
    
    var is_first_in_time_group = false
}

struct Time {
    
    enum Mode {
        case hour
        case date
    }
    
    let start: Date
    let end: Date
}

class EventInvitationWrapper {
    let invitation: EventInvitation
    
    required init(_ invitation: EventInvitation) {
        self.invitation = invitation
    }
}

struct EventInvitation {
    let id: String
    let from_uid: String
    let to_uid: String
    let eid: String
    
    let event: Event
    let from_profile: Profile
}

enum AgeRange: String {
    case all = "All"
    case five_plus = "5+"
    case thirteen_plus = "13+"
    case eighteen_plus = "18+"
    case twenty_one_plus = "21+"
}

enum Tag: String {
    case food_drink = "Food/Drink"
    case clubs = "Clubs"
    case sports = "Sports"
    case education = "Education"
    case entertainment = "Entertainment"
    case music = "Music"
    case social = "Social"
    case religious = "Religious"
    case deals = "Deals"
    case other = "Other"
}

extension Event {
    
    static func load(with dictionary: [String: AnyObject], completion: @escaping (Event?) -> Void) {
        guard let title = dictionary[DBChildren.Event.title] as? String,
            let description = dictionary[DBChildren.Event.description] as? String,
            let tag = dictionary[DBChildren.Event.tag] as? String,
            let ages = dictionary[DBChildren.Event.ages] as? String,
            let id = dictionary[DBChildren.Event.id] as? String,
            let uid = dictionary[DBChildren.Event.uid] as? String,
            let bg = dictionary[DBChildren.Event.cell_background_name] as? String,
            let start = dictionary[DBChildren.Event.start_time] as? TimeInterval,
            let end = dictionary[DBChildren.Event.end_time] as? TimeInterval,
            let accessibility = dictionary[DBChildren.Event.accessibility] as? String
            else {
                completion(nil)
                return
        }
        
        let gid = dictionary[DBChildren.Event.gid] as? String
        let start_date = Date(timeIntervalSince1970: start)
        let end_date = Date(timeIntervalSince1970: end)
        
        let event = Event(title, description, Tag(rawValue: tag)!, AgeRange(rawValue: ages)!, id, uid, gid, bg, Time(start: start_date, end: end_date), accessibility)
        
        if let place_id = dictionary[DBChildren.Event.place_id] as? String {
            let places_client = GMSPlacesClient()
            places_client.lookUpPlaceID(place_id, callback: { (place, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                
                event.place = place
                Caches.events.setObject(event, forKey: event.id as Caches.EventID)
                completion(event)
            })
        }
    }
    
    static func load(withID eid: String, completion: @escaping (Event?) -> Void) {
        
        Database.database().reference().child(DBChildren.events).child(eid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            Event.load(with: dictionary) { event in
                completion(event)
            }
        })

    }
    
    static func getAllEvents(with eids: [String], query: DatabaseQuery?, completion: @escaping (_ events: [Event]) -> Void) {
        var events = [Event]()
        let dispatch_group = DispatchGroup()
        let ref = query?.ref ?? Database.database().reference().child(DBChildren.events)
        
        for eid in eids {
            
            if let event = Caches.events.object(forKey: eid as Caches.EventID) {
                print("event found in cache")
                events.append(event)
                continue
            }
            
            dispatch_group.enter()
            ref.child(eid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                dispatch_group.enter()
                Event.load(with: dictionary) { event in
                    if let event = event {
                        events.append(event)
                    }
                    dispatch_group.leave()
                }
                dispatch_group.leave()
            })
        }
        
        dispatch_group.notify(queue: DispatchQueue.main) {
            completion(events)
        }
    }
    
    static func remove(_ eid: String, _ gid: String?) {
        
        let ref = Database.database().reference()
        let dispatch_group = DispatchGroup()
        
        // remove event from attending users
        dispatch_group.enter()
        ref.child(DBChildren.event_attendees).child(eid).observeSingleEvent(of: .value, with: { snapshot in
            guard let uids = (snapshot.value as? [String: AnyObject])?.keys else { return }
            for uid in Array(uids) {
                ref.child(DBChildren.user_events).child(uid).child(eid).removeValue()
            }
            dispatch_group.leave()
        })
        
        // remove all invitations to this event
        dispatch_group.enter()
        ref.child(DBChildren.event_invitations).queryOrdered(byChild: DBChildren.Invitation.eid).queryEqual(toValue: eid).observeSingleEvent(of: .value, with: { snapshot in
            
            if let invitations_ids = (snapshot.value as? [String: AnyObject])?.keys {
                dispatch_group.enter()
                loadInvitations(with: Array(invitations_ids)) { invitations in
                    for inv in invitations {
                        ref.child(DBChildren.user_event_invitations).child(inv.to_uid).child(inv.id).removeValue()
                    }
                    dispatch_group.leave()
                }
            }
            dispatch_group.leave()
        })
        
        // remove from all my crowds
        dispatch_group.enter()
        ref.child(DBChildren.user_my_crowds_events).queryOrdered(byChild: eid).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { snapshot in
            
            if let uids_dict = snapshot.value as? [String: AnyObject] {
                let uids = Array(uids_dict.keys)
                for uid in uids {
                    ref.child(DBChildren.user_my_crowds_events).child(uid).child(eid).removeValue()
                }
            }
            dispatch_group.leave()
        })
        
        dispatch_group.notify(queue: .main) {
            // remove event from its group if it has one
            if let gid = gid {
                ref.child(DBChildren.group_events).child(gid).child(eid).removeValue()
            }
            
            // remove event data
            ref.child(DBChildren.events).child(eid).removeValue()
            
            // remove node containing attendees
            ref.child(DBChildren.event_attendees).child(eid).removeValue()
        }
        
    }
    
    static func attend(_ uid: String, _ eid: String) {
        let ref = Database.database().reference()
        ref.child(DBChildren.user_events).child(uid).child(eid).setValue(true)
        ref.child(DBChildren.event_attendees).child(eid).child(uid).setValue(true)
        
        /*
        ref.child(DBChildren.events).child(eid).child(DBChildren.Event.going).runTransactionBlock { current_value -> TransactionResult in
            if let value = current_value.value as? Int {
                current_value.value = value + 1
            }
            return TransactionResult.success(withValue: current_value)
        }*/
        
        // remove any invitations to this event
        
        ref.child(DBChildren.user_event_invitations).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let ids = (snapshot.value as? [String: AnyObject])?.keys else { return }
            Event.loadInvitations(with: Array(ids)) { invitations in
                for inv in invitations {
                    if inv.eid == eid {
                        removeInvitation(inv)
                    }
                }
            }
        })
        
        Event.addToMyCrowds(eid, uid)
    }
    
    static func cancelAttendence(_ uid: String, _ eid: String) {
        let ref = Database.database().reference()
        ref.child(DBChildren.user_events).child(uid).child(eid).removeValue()
        ref.child(DBChildren.event_attendees).child(eid).child(uid).removeValue()
        
        /*
        ref.child(DBChildren.events).child(eid).child(DBChildren.Event.going).runTransactionBlock { current_value -> TransactionResult in
            if let value = current_value.value as? Int {
                current_value.value = value - 1
            }
            return TransactionResult.success(withValue: current_value)
        }*/
    }
    
    static func isAttending(_ uid: String, _ eid: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference()
        ref.child(DBChildren.user_events).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let events_dict = snapshot.value as? [String : AnyObject] else {
                completion(false)
                return
            }
            if let _ = events_dict[eid] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func invite(_ uid: String, _ eid: String) {
        let ref = Database.database().reference()
        
        let invitation_key = ref.child(DBChildren.event_invitations).childByAutoId().key
        let invitation_dict = [
            DBChildren.Invitation.id: invitation_key,
            DBChildren.Invitation.from_uid: Auth.auth().currentUser!.uid,
            DBChildren.Invitation.to_uid: uid,
            DBChildren.Invitation.eid: eid
        ]
        
        ref.child(DBChildren.event_invitations).child(invitation_key).setValue(invitation_dict)
        ref.child(DBChildren.user_event_invitations).child(uid).child(invitation_key).setValue(true)
        Event.addToMyCrowds(eid, uid)
    }
    
    static func addToMyCrowds(_ eid: String, _ uid: String) {
        Database.database().reference().child(DBChildren.user_my_crowds_events).child(uid).child(eid).setValue(true)
    }
    
    static func isInMyCrowds(_ eid: String, _ uid: String, completion: @escaping (Bool) -> Void) {
        Database.database().reference().child(DBChildren.user_my_crowds_events).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.hasChild(eid))
        })
    }
    
    static func loadInvitations(with ids: [String], completion: @escaping ([EventInvitation]) -> Void) {
        var invitations = [EventInvitation]()
        let dispatch_group = DispatchGroup()
        
        for id in ids {
            
            if let invitation = Caches.event_invitations.object(forKey: id as Caches.EventInvitationID) {
                invitations.append(invitation.invitation)
                continue
            }
            
            dispatch_group.enter()
            loadInvitation(with: id) { invitation in
                if let inv = invitation {
                    invitations.append(inv)
                }
                dispatch_group.leave()
            }
        }
        
        dispatch_group.notify(queue: DispatchQueue.main) {
            completion(invitations)
        }
    }
    
    static func loadInvitation(with id: String, completion: @escaping (EventInvitation?) -> Void) {
        Database.database().reference().child(DBChildren.event_invitations).child(id).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject] {
                loadInvitation(with: dict, completion: completion)
            }
        })
    }
    
    private static func loadInvitation(with dictionary: [String: AnyObject], completion: @escaping (EventInvitation?) -> Void) {
        guard let from_uid = dictionary[DBChildren.Invitation.from_uid] as? String,
            let eid = dictionary[DBChildren.Invitation.eid] as? String
            else {
                completion(nil)
                return
        }
        
        let dispatch_group = DispatchGroup()
        
        var event_invitation: EventInvitation!
        var is_expired = false
        
        dispatch_group.enter()
        Profile.initProfile(with: from_uid) { profile in
            dispatch_group.enter()
            Event.load(withID: eid) { event in
                
                guard let id = dictionary[DBChildren.Invitation.id] as? String,
                    let to_uid = dictionary[DBChildren.Invitation.to_uid] as? String,
                    let event = event,
                    let profile = profile
                    else {
                        completion(nil)
                        return
                }
        
                event_invitation = EventInvitation(id: id, from_uid: from_uid, to_uid: to_uid, eid: eid, event: event, from_profile: profile)
                
                if event.state == .ended {
                    removeInvitation(event_invitation)
                    is_expired = true
                }
                
                dispatch_group.leave()
            }
            dispatch_group.leave()
        }
        
        dispatch_group.notify(queue: .main) {
            guard !is_expired else { return }
            Caches.event_invitations.setObject(EventInvitationWrapper(event_invitation), forKey: event_invitation.id as Caches.EventInvitationID)
            completion(event_invitation)
        }
    }
    
    static func removeInvitation(_ invitation: EventInvitation) {
        let ref = Database.database().reference()
        ref.child(DBChildren.event_invitations).child(invitation.id).removeValue()
        ref.child(DBChildren.user_event_invitations).child(invitation.to_uid).child(invitation.id).removeValue()
        Caches.event_invitations.removeObject(forKey: invitation.id as Caches.EventInvitationID)
    }
    
    static func removeInvitation(for_eid eid: String, _ to_uid: String) {
        let ref = Database.database().reference()
        
        ref.child(DBChildren.event_invitations).queryOrdered(byChild: DBChildren.Invitation.eid).queryEqual(toValue: eid).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let dict = snapshot.value as? [String: AnyObject] else {
                print("invalid invitation snapshot")
                return
            }
            
            if dict[DBChildren.Invitation.to_uid] as! String == to_uid {
                loadInvitation(with: dict) { invitation in
                    if let invitation = invitation {
                        removeInvitation(invitation)
                    }
                    else {
                        print("no invitation to remove")
                    }
                }
            }
        })
    }
    
    static func getNumberOfAttendees(forEID eid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.event_attendees).child(eid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount)
        })
    }
    
    static func getNumberOfInvitations(forUID uid: String, completion: @escaping (UInt) -> Void) {
        Database.database().reference().child(DBChildren.user_event_invitations).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.childrenCount)
        })
    }
}
