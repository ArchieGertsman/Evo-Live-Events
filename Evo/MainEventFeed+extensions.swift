//
//  Feed+handlers.swift
//  Evo
//
//  Created by Admin on 5/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase
import UIKit
import CoreLocation

extension MainEventFeedController {
    
    func observeAddedEvents() {
        self.events_query.observe(.childAdded, with: { (snapshot) in
            if let event = Caches.events.object(forKey: snapshot.key as Caches.EventID) {
                self.add(event)
            }
            else {
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.addEvent(withDict: dictionary)
                }
                else {
                    self.addEvent(withID: snapshot.key)
                }
            }
        })
    }
    func observeChangedEvents() {
        self.events_query.observe(.childChanged, with: { (snapshot) in
            print("changed event")
            if let dictionary = snapshot.value as? [String : AnyObject] {
                self.changeEvent(withDict: dictionary)
            }
            else {
                self.changeEvent(withID: snapshot.key)
            }
        })
    }

    func observeRemovedEvents() {
        self.events_query.observe(.childRemoved, with: { (snapshot) in
            print("removed event")
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

// helpers
extension MainEventFeedController {
    
    internal func add(_ event: Event) {
        let event_feed_datasource = self.datasource as! EventFeedDatasource
        if self.shouldAdd(event) && !event_feed_datasource.sorted_events.contains { $0.id == event.id } {
            event_feed_datasource.add(event)
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    internal func addEvent(withDict dict: [String: AnyObject]) {
        Event.load(with: dict) { event in
            if let event = event {
                self.add(event)
            }
        }
    }
    
    internal func addEvent(withID id: String) {
        Event.load(withID: id) { event in
            if let event = event {
                self.add(event)
            }
        }
    }
    
    private func change(_ event: Event) {
        (self.datasource as! EventFeedDatasource).change(event)
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    internal func changeEvent(withDict dict: [String: AnyObject]) {
        Event.load(with: dict) { event in
            if let event = event {
                self.change(event)
            }
        }
    }
    
    internal func changeEvent(withID id: String) {
        Event.load(withID: id) { event in
            if let event = event {
                self.change(event)
            }
        }
    }
    
}
