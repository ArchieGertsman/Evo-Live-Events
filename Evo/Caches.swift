//
//  Caches.swift
//  Evo
//
//  Created by Admin on 7/27/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation

/* struct which stores the caches used in this app */
struct Caches {
    typealias EventID = NSString
    typealias EventInvitationID = NSString
    typealias GroupPendingRequestID = NSString
    
    static var events = NSCache<EventID, Event>()
    static var event_invitations = NSCache<EventInvitationID, EventInvitationWrapper>()
    static var pending_requests = NSCache<GroupPendingRequestID, PendingRequestWrapper>()
}
