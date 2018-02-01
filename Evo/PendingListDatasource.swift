//
//  PendingListDatasource.swift
//  Evo
//
//  Created by Admin on 6/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

class PendingListDatasource: Datasource {
    
    var entries = [PendingRequest]()
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [EvoFooter.self]
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return self.entries.isEmpty ? "You have no new pending requests." : nil
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [PendingListCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return entries[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return entries.count
    }
    
}
