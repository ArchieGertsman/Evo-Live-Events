//
//  GroupDatasource.swift
//  Evo
//
//  Created by Admin on 6/18/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

class GroupDatasource: EventFeedDatasource {
    
    var group: Group
    var is_current_user_in_group: Bool
    
    required init(_ group: Group, is_current_user_in_group: Bool) {
        self.group = group
        self.is_current_user_in_group = is_current_user_in_group
        super.init(.date)
    }
    
    required init(_ time_mode: Time.Mode) {
        fatalError("init has not been implemented")
    }

    override func headerItem(_ section: Int) -> Any? {
        return group
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return EventFeedFooterData(event_feed_type: .group, is_private: self.group.is_private, is_feed_empty: self.sorted_events.isEmpty, is_current_user_in_group: self.is_current_user_in_group)
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return (self.is_current_user_in_group || !self.group.is_private) ? sorted_events.count : 0
    }
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [GroupHeader.self]
    }
    
}
