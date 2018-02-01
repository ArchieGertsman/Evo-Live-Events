//
//  FeedController.swift
//  Evo
//
//  Created by Admin on 5/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents
import Foundation

/* Live event feed controller. Either displays all public events or my crowds */
class MainEventFeedController: EventFeedController {
    
    var events_query: DatabaseQuery! // database reference to the events node, filtered by distance
    let refresh_control = UIRefreshControl() // for refreshing the feed if the user swipes the screen downwords at the top
    
    var entity_id: String?
    
    // c-tor that tells the feed to sort by hour.
    init() {
        super.init(time_mode: .hour)
    }
    
    required init(time_mode: Time.Mode) {
        fatalError("init(time_mode:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleRefresh() {
        self.events_query.removeAllObservers()
        self.updateQuery()
        self.clearEvents()
        self.observeAllEvents()
        self.refresh_control.endRefreshing()
    }
    
    private func clearEvents() {
        (self.datasource as! EventFeedDatasource).clearEvents()
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: "Feed")
        
        refresh_control.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged) // tell the UIRefreshControl how to do its job
        self.collectionView?.addSubview(refresh_control) // add UIRefreshControll to the controller
        
        self.datasource = EventFeedDatasource(self.time_mode) // set the datasource
    }
    
    // override if necessary
    internal func updateQuery() { }
    
    // reload/update everything when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // if an event was removed from the event cache then make sure to remove it from this feed
        for event in (self.datasource as! EventFeedDatasource).sorted_events {
            if Caches.events.object(forKey: event.id as Caches.EventID) == nil {
                (self.datasource as! EventFeedDatasource).remove(event, decache: false)
            }
        }
        
        self.collectionView?.reloadData()
        self.updateQuery()
        (self.datasource as? EventFeedDatasource)?.updateTimeMarkers()
        self.observeAllEvents()
    }
    
    // respond to any changes in the database regarding events that satisfy this query
    private func observeAllEvents() {
        self.observeAddedEvents()
        self.observeChangedEvents()
        self.observeRemovedEvents()
    }
    
    // free database reference when view disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.events_query.removeAllObservers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // must be implemented in deriving controller. Determines whether an event should be added to feed.
    internal func shouldAdd(_ event: Event) -> Bool {
        fatalError("MainEventFeedController.shouldAdd not implemented")
    }

}
