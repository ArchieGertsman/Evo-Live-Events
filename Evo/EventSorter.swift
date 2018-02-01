//
//  EventSorter.swift
//  Evo
//
//  Created by Admin on 6/11/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation

/* Class which contains the function for inserting an event into a feed */
class EventSorter {
    
    typealias EventID = String
    
    /* inserts an event into an event dictionary, given the sorting mode of the feed (by hour or by day).
     * The dictionary's keys are Date objects which are truncated to the precision of hours if the sorting mode
     * is by hour or to the precision of days if the sorting mode is by day.
     */
    class func insert(_ event: Event, into dict: inout Dictionary<Date, [Event]>, by sort_mode: Time.Mode) {
        
        // if location isn't enable then return
        guard event.distance_from_me != nil else { print("distance from me is nil"); return }
        
        var components: DateComponents // components representing the date of the event
        
        // select precision of the date of the event based on the sorting mode
        switch sort_mode {
            
        // if mode is .date then use mm/dd/yy
        case .date: components = Calendar.current.dateComponents([.year, .month, .day], from: event.time.start)
            
        // if mode is .hour then use dd/hh if event is today else use dd
        case .hour: components = Calendar.current.isDateInToday(event.time.start) ? Calendar.current.dateComponents([.day, .hour], from: event.time.start) : Calendar.current.dateComponents([.day], from: event.time.start)
        }
        
        // custom Date object constructed from the above components
        let truncated_date = Calendar.current.date(from: components)!
        
        // insert the event
        
        if let _ = dict[truncated_date] {
            // if an event array is mapped to the constructed date then insert the event in the array
            
            // get insersion index for the event
            let index = dict[truncated_date]!.insertionIndexOf(elem: event) {
                switch sort_mode {
                // if sorting mode is by hour then sort the events mapped to that hour by distance from least to greatest
                case .hour: return $0.distance_from_me! < $1.distance_from_me!
                    
                // if sorting mode is by date then sort the events mapped to that date by time from soonest to latest
                case .date: return $0.time.start < $1.time.start
                }
            }
            dict[truncated_date]!.insert(event, at: index) // insert event at insertion index
            
            // mark the first event in the event array mapped to this constructed as such
            for event in dict[truncated_date]! {
                event.is_first_in_time_group = false
            }
            dict[truncated_date]![0].is_first_in_time_group = true
        }
        else {
            // else map a new event array for the constructed date in the dictionary and add the event
            event.is_first_in_time_group = true
            dict[truncated_date] = [event]
        }
        
        
    }
    
}
