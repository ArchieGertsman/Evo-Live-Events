//
//  PendingListController.swift
//  Evo
//
//  Created by Admin on 6/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

class PendingListController: EntityListController {

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
        self.initEvoStyle(title: "Pending Requests")
        self.entities_ref = Database.database().reference().child(DBChildren.pending_requests_for_users).child(self.id)
        self.datasource = PendingListDatasource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.entities_ref.observe(.value, with: { (snapshot) in
            guard let ids_dict = snapshot.value as? [String : AnyObject] else {
                
                if let pending_request_list_datasource = self.datasource as? PendingListDatasource {
                    pending_request_list_datasource.entries = [PendingRequest]()
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
                return
            }
            let ids = Array(ids_dict.keys)
            
            PendingRequest.initPendingRequests(with: ids) { pending_requests in
                guard let pending_request_list_datasource = self.datasource as? PendingListDatasource else { return }
                
                pending_request_list_datasource.entries = pending_requests
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }

}
