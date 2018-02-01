//
//  HomeDataSource.swift
//  Evo
//
//  Created by Admin on 4/14/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase
import LBTAComponents

class EventFeedDatasource: Datasource {
    
    var sorted_events_by_date = Dictionary<Date, [Event]>()
    var sorted_events: [Event] {
        // print(1)
        var ret = [Event]()
        
        let sorted_date_keys = Array(self.sorted_events_by_date.keys).sorted { $0.compare($1) == (self.time_mode == .hour ? .orderedAscending : .orderedDescending) }
        
        for date in sorted_date_keys {
            ret.append(contentsOf: self.sorted_events_by_date[date]!)
        }
        
        return ret
    }
    
    let time_mode: Time.Mode
    
    func add(_ event: Event) {
        print("added event in datasource")
        EventSorter.insert(event, into: &self.sorted_events_by_date, by: self.time_mode)
        Caches.events.setObject(event, forKey: event.id as Caches.EventID)
    }
    
    private func update(_ event: Event, completion: @escaping (_ index: Int?, _ date: Date) -> Void) {
        print(2)
        var components: DateComponents
        
        switch self.time_mode {
        case .date: components = Calendar.current.dateComponents([.year, .month, .day], from: event.time.start)
        case .hour: components = !Calendar.current.isDateInTomorrow(event.time.start) ? Calendar.current.dateComponents([.day, .hour], from: event.time.start) :
            Calendar.current.dateComponents([.day], from: event.time.start)
        }
        
        let truncated_date = Calendar.current.date(from: components)!
        
        let old_event_index = self.sorted_events_by_date[truncated_date]?.index { $0.id == event.id }
        
        completion(old_event_index, truncated_date)
    }
    
    func remove(_ event: Event, decache: Bool) {
        print(3)
        self.update(event) { index, date in
            
            guard let index = index else { print("fail"); return }
            print("removing from sorted events")
            self.sorted_events_by_date[date]?.remove(at: index)
            self.updateTimeMarker(forDate: date)
            if decache {
                Caches.events.removeObject(forKey: event.id as Caches.EventID)
            }
        }
    }
    
    func change(_ event: Event) {
        print("changed event in datasource")
        self.update(event) { index, date in
            
            guard let index = index else { return }
            
            self.sorted_events_by_date[date]?[index] = event
            self.updateTimeMarker(forDate: date)
            Caches.events.setObject(event, forKey: event.id as Caches.EventID)
        }
    }
    
    private func updateTimeMarker(forDate date: Date) {
        print(4)
        guard let events = self.sorted_events_by_date[date],
            events.count > 0 else { return }
        
        for event in events {
            event.is_first_in_time_group = false
        }
        events[0].is_first_in_time_group = true
    }
    
    func updateTimeMarkers() {
        print(4)
        for (_, events) in sorted_events_by_date {
            
            guard events.count > 0 else { continue }
            
            for event in events {
                event.is_first_in_time_group = false
            }
            events[0].is_first_in_time_group = true
        }
    }
    
    func clearEvents() {
        self.sorted_events_by_date = Dictionary<Date, [Event]>()
    }
    /*
    var events = [Event]() {
        didSet {
            print("changed events in datasource")
            self.sorted_events_by_date = EventSorter.getSortedEvents(from: self.events, by: self.time_mode)
        }
    }*/
    
    required init(_ time_mode: Time.Mode) {
        self.time_mode = time_mode
        super.init()
    }
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [DatasourceCell.self]
    }
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [EventFeedFooter.self]
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return EventFeedFooterData(event_feed_type: .main, is_private: false, is_feed_empty: self.sorted_events.isEmpty, is_current_user_in_group: nil)
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [EventFeedCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        // print("item")
        return sorted_events[indexPath.item]
        // return Array()[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        print("count", sorted_events.count)
        return sorted_events.count
    }
    
}
