//
//  EventAttendeesListController.swift
//  Evo
//
//  Created by Admin on 7/23/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

/* shoes all the people attending an event */
class EventAttendeesListController: EntityListController {
    
    let event: Event
    
    required init(for event: Event) {
        self.event = event
        super.init(event.id)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ id: String) {
        fatalError("init has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: event.state != .ended ? "Going" : "Went")
  
        self.datasource = ProfileListDatasource()
        self.entities_ref = Database.database().reference().child(DBChildren.event_attendees).child(self.id)
        
        self.observeAllEntities { ids in
            Profile.initProfiles(with: ids) { profiles in
                guard let people_list_datasource = self.datasource as? ProfileListDatasource else { return }
                
                people_list_datasource.profiles = profiles
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
}
