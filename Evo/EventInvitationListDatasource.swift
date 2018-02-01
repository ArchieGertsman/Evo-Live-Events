//
//  EventInvitationDatasource.swift
//  Evo
//
//  Created by Admin on 8/2/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

class EventInvitationListDatasource: Datasource {
    
    var invitations = [EventInvitation]()
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [EvoFooter.self]
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return self.invitations.isEmpty ? "You have no new invitations." : nil
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [EventInvitationCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return invitations[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return invitations.count
    }
    
}
