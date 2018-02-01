//
//  Following+handlers.swift
//  Evo
//
//  Created by Admin on 6/10/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

extension EntityListController {
 
    internal func observeAllEntities(completion: @escaping ([String]) -> Void) {
        self.entities_ref.observe(.value, with: { (snapshot) in
            guard let ids_dict = snapshot.value as? [String : AnyObject] else { return }
            let ids = Array(ids_dict.keys)
            completion(ids)
        })
    }
    
    internal func observeAddedEntities(completion: @escaping (String) -> Void) {
        self.entities_ref.observe(.childAdded, with: { snapshot in
            completion(snapshot.key)
        })
    }
    
    internal func observeRemovedEntities(completion: @escaping (String) -> Void) {
        self.entities_ref.observe(.childRemoved, with: { snapshot in
            completion(snapshot.key)
        })
    }
}

extension EntityListController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // spacing between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: EventFeedFooter.normal_height)
    }
    
}
