//
//  EntityController.swift
//  Evo
//
//  Created by Admin on 6/20/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

/* controller which displays a profile or a group */
class EntityController: EventFeedController {

    var entity_ref: DatabaseReference! // reference to the entity's node in the database
    var event_ids_ref: DatabaseReference! // reference to the entity's events node
    
    // c-tor which tells the feed to sort events by date
    init() {
        super.init(time_mode: .date)
    }
    
    required init(time_mode: Time.Mode) {
        fatalError("init(time_mode:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // this needs to be implemented in a deriving class
    func shouldAdd(_ event: Event, completion: @escaping (Bool) -> Void) -> Void {
        fatalError("Entity Controller shouldAdd not implemented")
    }
    
    // free database references when view disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.event_ids_ref.removeAllObservers()
        self.entity_ref.removeAllObservers()
    }

}
