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
    
    var sorted_events = [Event]()
    
    var events = [Event]() {
        didSet {
            
            print("count: \(events.count)")
            
            if let sorted_events = EventSorter.getSortedEvents(from: self.events, by: .hour) {
                self.sorted_events = sorted_events
            }
        }
    }
    
    convenience init(events: [Event]) {
        self.init()
        self.events = events
    }
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [EventFeedFooter.self]
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [EventFeedCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return sorted_events[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return sorted_events.count
    }
    
}
