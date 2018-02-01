//
//  DBChildren.swift
//  Evo
//
//  Created by Admin on 7/15/17.
//  Copyright © 2017 Evo. All rights reserved.
//

/* struct containing all of the children in the database to prevent hardcoding them */
struct DBChildren {
    static let users = "users"
    static let user_events = "user-events"
    static let user_followings = "user-followings"
    static let user_followers = "user-followers"
    static let user_groups = "user-groups"
    static let user_pending_requests = "user-pending-requests"
    static let user_event_invitations = "user-event-invitations"
    static let user_my_crowds_events = "user-my-crowds-events"
    
    struct User {
        static let id = "id"
        static let name = "name"
        static let email = "email"
        static let location = "location"
        static let profile_image_url = "profile-image-url"
        static let phone = "phone"
        static let gender = "gender"
        static let age = "age"
    }
    
    static let events = "events"
    static let event_attendees = "event-attendees"
    
    struct Event {
        static let id = "id"
        static let uid = "uid"
        static let gid = "gid"
        static let title = "title"
        static let cell_background_name = "cell-background-name"
        static let description = "description"
        static let start_time = "start-time"
        static let end_time = "end-time"
        static let place_id = "place-id"
        static let raw_location = "raw-location"
        static let tag = "tag"
        static let ages = "ages"
        static let privacy = "private"
        static let accessibility  = "accessibility"
    }
    
    static let groups = "groups"
    static let group_members = "group-members"
    static let group_events = "group-events"
    
    struct Group {
        static let id = "id"
        static let owner_uid = "owner-uid"
        static let name = "name"
        static let image_url = "image-url"
        static let description = "description"
        static let privacy = "private"
    }
    
    static let pending_requests = "pending-requests"
    static let pending_requests_for_users = "pending-requests-for-users"
    
    struct PendingRequest {
        static let id = "id"
        static let from_uid = "from-uid"
        static let gid = "gid"
        static let timestamp = "timestamp"
    }
    
    static let user_notification_tokens = "user-notification-tokens"
    
    static let event_invitations = "event-invitations"
    
    struct Invitation {
        static let id = "id"
        static let from_uid = "from-uid"
        static let to_uid = "to-uid"
        static let eid = "eid"
    }
}
