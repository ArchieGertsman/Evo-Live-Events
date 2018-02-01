//
//  FollowingController.swift
//  Evo
//
//  Created by Admin on 6/10/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents
import Firebase

/* controller which displays a collection of entities, e.g. a list of all the people someone is following */
class EntityListController: DatasourceController {
    
    let id: String // id of the entity to whom this list pertains, e.g. the id of the user to whom a following list belongs
    var entities_ref: DatabaseReference! // database reference to the node containing the list of entities
    
    required init(_ id: String) {
        self.id = id
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // free database reference when view disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.entities_ref.removeAllObservers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // set height of each cell to 80
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: view.frame.width, height: 80)
    }
    
}
