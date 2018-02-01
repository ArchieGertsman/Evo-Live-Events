//
//  GroupListDatasource.swift
//  Evo
//
//  Created by Admin on 7/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

class GroupListDatasource: Datasource {
    
    var groups = [Group]()
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [DatasourceCell.self]
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return DatasourceCell()
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [GroupListCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return groups[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return groups.count
    }
    
}
