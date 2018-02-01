//
//  Entity+extensions.swift
//  Evo
//
//  Created by Admin on 6/20/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase

extension EntityController {
    
    internal func observeEvents() {
        self.observeAddedEvents()
        self.observeRemovedEvents()
    }
    
    private func observeAddedEvents() {
        print("observe added events")
        (self.datasource as? EventFeedDatasource)?.clearEvents()
        self.event_ids_ref.observe(.childAdded, with: { (snapshot) in
            
            if let event = Caches.events.object(forKey: snapshot.key as Caches.EventID) {
                
                guard let event_feed_datasource = self.datasource as? EventFeedDatasource else {
                    print("no datasource")
                    return }
                
                // event in cache
                self.shouldAdd(event) { bool in
                    bool ? event_feed_datasource.add(event) : event_feed_datasource.change(event)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
            }
            else {
        
                Event.load(withID: snapshot.key) { event in
                    guard let event = event, let event_feed_datasource = self.datasource as? EventFeedDatasource else { return }
                    
                    // event not in cache
                    
                    self.shouldAdd(event) { bool in
                        bool ? event_feed_datasource.add(event) : event_feed_datasource.change(event)
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                }
                
            }
        })
    }
    
    private func observeRemovedEvents() {
        self.event_ids_ref.observe(.childRemoved, with: { (snapshot) in
            guard let event_feed_datasource = self.datasource as? EventFeedDatasource else { return }
            
            if let event = Caches.events.object(forKey: snapshot.key as Caches.EventID) {
                event_feed_datasource.remove(event, decache: true)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
            
        })
    }

}
