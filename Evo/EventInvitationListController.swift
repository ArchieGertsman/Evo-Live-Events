//
//  EventInvitationListController.swift
//  Evo
//
//  Created by Admin on 8/2/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

class EventInvitationListController: EntityListController {

    init() {
        super.init(Auth.auth().currentUser!.uid)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ id: String) {
        fatalError("init has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: "Event Invitations")
        self.entities_ref = Database.database().reference().child(DBChildren.user_event_invitations).child(self.id)
        self.datasource = EventInvitationListDatasource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.entities_ref.observe(.value, with: { (snapshot) in
            guard let ids_dict = snapshot.value as? [String : AnyObject] else {
                
                if let invitation_list_datasource = self.datasource as? EventInvitationListDatasource {
                    invitation_list_datasource.invitations = [EventInvitation]()
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
                return
            }
            let ids = Array(ids_dict.keys)
            
            Event.loadInvitations(with: ids) { invitations in
                guard let invitation_list_datasource = self.datasource as? EventInvitationListDatasource else { return }
                
                invitation_list_datasource.invitations = invitations
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }


}
