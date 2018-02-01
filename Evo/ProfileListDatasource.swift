//
//  ProfileListDatasource.swift
//  Evo
//
//  Created by Admin on 7/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

class ProfileListDatasource: Datasource {
    
    var profiles = [Profile]()
    var for_group: Bool?
    
    convenience init(forGroup: Bool) {
        self.init()
        self.for_group = forGroup
    }
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [DatasourceCell.self]
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return DatasourceCell()
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [(self.for_group ?? false) ? GroupMemberListCell.self : ProfileListCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return profiles[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return profiles.count
    }
    
}
