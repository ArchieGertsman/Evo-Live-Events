//
//  PublicEventFeedController.swift
//  Evo
//
//  Created by Admin on 9/4/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import Firebase

/* public feed tab controller */
class PublicEventFeedController: MainEventFeedController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateQuery()
        
        Analytics.setScreenName("public_feed", screenClass: "PublicEventFeedController")
    }
    
    override func updateQuery() {
        self.events_query = Database.database().reference().child(DBChildren.events).queryOrdered(byChild: DBChildren.Event.end_time).queryStarting(atValue: Date().timeIntervalSince1970)
    }
    
    // determines whether an event should be added to the feed based on the criteria of the filter and time
    override func shouldAdd(_ event: Event) -> Bool {
        let current_time = Date()
        guard current_time < event.time.end else { return false } // current time can't be later than event's end time
        
        // if filter is enabled then follow its criteria
        if let filter = (self.viewController as? MainEventFeedTabBarController)?.filter {
            /* event start time must be between the earliest and latest time (inclusive).
             * If only an earliest time is specified, then the event start time must be at or later than that time.
             * If only a latest time is specified, then the event start time must be at or before that time.
             */
            
            if let earliest_time = filter.earliest_time, event.time.start < earliest_time {
                return false
            }
            
            if let end_time = filter.latest_time, event.time.start > end_time {
                return false
            }
            
            // event has to be public, within range, and must fit ages and tags if specified
            return event.accessibility == .public_ &&
                UInt(event.distance_from_me!) <= filter.distance &&
                (filter.age_ranges.contains(event.ages) || filter.age_ranges.isEmpty) &&
                (filter.tags.contains(event.tag) || filter.tags.isEmpty)
        }
        
        // if filter is disabled then the event must be public and whithin default range
        if let default_radius = default_event_radius {
            return event.distance_from_me! <= Double(default_radius) && event.accessibility == .public_
        }
        
        return event.accessibility == .public_
    }
    
}
