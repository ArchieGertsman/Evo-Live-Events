//
//  MyCrowdsEventFeedController.swift
//  Evo
//
//  Created by Admin on 8/20/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents
import Foundation

class MyCrowdsEventFeedController: MainEventFeedController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.events_query = Database.database().reference().child(DBChildren.user_my_crowds_events).child(Auth.auth().currentUser!.uid)
        
        Analytics.setScreenName("my_crowds_feed", screenClass: "MyCrowdsEventFeedController")
    }
    
    // Same as PublicEventFeedController implimentation except the event doesn't need to be public to return true
    override func shouldAdd(_ event: Event) -> Bool {
        let current_time = Date()
        guard current_time < event.time.end else { return false }
        
        if let filter = (self.viewController as? MainEventFeedTabBarController)?.filter {
            if let earliest_time = filter.earliest_time, event.time.start < earliest_time {
                return false
            }
            
            if let end_time = filter.latest_time, event.time.start > end_time {
                return false
            }
            
            return event.distance_from_me! <= Double(filter.distance) &&
                (filter.age_ranges.contains(event.ages) || filter.age_ranges.isEmpty) &&
                (filter.tags.contains(event.tag) || filter.tags.isEmpty)
        }
        
        if let default_radius = default_event_radius {
            return event.distance_from_me! <= Double(default_radius)
        }
        
        return true
    }
}
