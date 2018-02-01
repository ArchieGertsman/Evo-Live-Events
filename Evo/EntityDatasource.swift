//
//  EntityDatasource.swift
//  Evo
//
//  Created by Admin on 6/20/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation

class EntityDatasource: Datasource {
    
    var sorted_events = [Event]()
    
    var entity = Entity()
    
    var events = [Event]() {
        didSet {
            if self.events.count > 0 {
                if let sorted_events = EventSorter.getSortedEvents(from: self.events, by: .date) {
                    self.sorted_events = sorted_events
                }
            }
        }
    }
    
    override func headerItem(_ section: Int) -> Any? {
        return group
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return self.group.is_private
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
        if let is_private = self.group.is_private, is_private {
            if let in_group = self.is_current_user_in_group, !in_group {
                return 0
            }
        }
        return sorted_events.count
    }
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [GroupHeader.self]
    }
    
}
