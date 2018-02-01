//
//  HomeDataSource.swift
//  Evo
//
//  Created by Admin on 4/14/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

class ProfileDatasource: EventFeedDatasource {
    
    var profile: Profile
    let profile_type: ProfileController.ProfileType
    
    required init(_ profile: Profile, _ profile_type: ProfileController.ProfileType) {
        self.profile = profile
        self.profile_type = profile_type
        super.init(.date)
    }
    
    required init(_ time_mode: Time.Mode) {
        fatalError("init has not been implemented")
    }
    
    override func headerItem(_ section: Int) -> Any? {
        return profile
    }
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return self.profile_type == .current_user ? [YourProfileHeader.self] : [OthersProfileHeader.self]
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return EventFeedFooterData(event_feed_type: .profile, is_private: false, is_feed_empty: self.sorted_events.isEmpty, is_current_user_in_group: nil)
    }
    
}
