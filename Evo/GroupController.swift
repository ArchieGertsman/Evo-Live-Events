//
//  GroupController.swift
//  Evo
//
//  Created by Admin on 6/18/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

/* display's a group's page */
class GroupController: EntityController {
    
    let group: Group
    
    required init(of group: Group) {
        self.group = group
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(time_mode: Time.Mode) {
        fatalError("init(time_mode:) has not been implemented")
    }
    
    // determines whether a given event should be added to this group page based on criteria
    override func shouldAdd(_ event: Event, completion: @escaping (Bool) -> Void) -> Void {
        // datasource may not be initialized yet
        guard let group_datasource = self.datasource as? GroupDatasource else {
            completion(false)
            return
        }
        
        if (group_datasource.sorted_events.contains { $0.id == event.id }) {
            completion(false)
        }
        
        // display the event if the current user is in the group or if the goup is public
        completion(group_datasource.is_current_user_in_group || !group_datasource.group.is_private)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: self.group.name)
        
        let ref = Database.database().reference()
        self.entity_ref = ref.child(DBChildren.groups).child(self.group.id)
        self.event_ids_ref = ref.child(DBChildren.group_events).child(self.group.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.observeGroup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
