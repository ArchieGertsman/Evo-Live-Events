//
//  PublicEventMapController.swift
//  Evo
//
//  Created by Admin on 9/4/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase

class PublicEventMapController: MapController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshQuery()
        
        Analytics.setScreenName("public_map", screenClass: "PublicEventMapController")
    }
    
    override func refreshQuery() {
         self.events_query = Database.database().reference().child(DBChildren.events).queryOrdered(byChild: DBChildren.Event.end_time).queryStarting(atValue: Date().timeIntervalSince1970)
    }
    
    // Same implimentation as PublicEventFeedController
    override func shouldAdd(_ event: Event) -> Bool {
        let current_time = Date()
        guard current_time < event.time.end else { return false }
        
        if let filter = (self.viewController as? MainEventFeedTabBarController)?.filter {
            if let start_time = filter.earliest_time, event.time.start > start_time {
                return false
            }
            if let end_time = filter.latest_time, event.time.end < end_time {
                return false
            }
            
            return event.accessibility == .public_ &&
                event.distance_from_me! <= Double(filter.distance) &&
                (filter.age_ranges.contains(event.ages) || filter.age_ranges.isEmpty) &&
                (filter.tags.contains(event.tag) || filter.tags.isEmpty)
        }
        
        if let default_radius = default_event_radius {
            return event.accessibility == .public_ && event.distance_from_me! <= Double(default_radius)
        }
        
        return event.accessibility == .public_
    }
    
}
