//
//  MapController.swift
//  Evo
//
//  Created by Tommy Nordberg on 5/18/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Firebase

/* constroller which displays a live map which displays event markers */
class MapController: EventFeedController {
    
    static var current_location: CLLocation? // used throughout the entire app to get the user's current location
    internal var events_query: DatabaseQuery! // database reference to the events node, filtered by distance
    internal var google_maps_view = GMSMapView()
    internal var location_manager = CLLocationManager()
    internal var markers = [GMSMarker]() // all of the event markers to be displayed on the map
    internal static var marker_view: UIImageView {
        let image_view = UIImageView(image: #imageLiteral(resourceName: "map_marker").withRenderingMode(.alwaysOriginal))
        image_view.frame = CGRect(x: 0, y: 0, width: 40, height: 40 * (5.0/3.0))
        image_view.contentMode = .scaleAspectFit
        return image_view
    }
    
    // c-tor which tells the feed to sort events by date. This is just required by the super class,
    // event though there technically isn't a feed that sorts things by time
    init() {
        super.init(time_mode: .hour)
    }
    
    required init(time_mode: Time.Mode) {
        fatalError("init(time_mode:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // refresh all the event markers
    override func handleRefresh() {
        self.google_maps_view.clear()
        self.markers = [GMSMarker]()
        self.events_query.removeAllObservers()
        self.refreshQuery()
        self.observeAllEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initEvoStyle(title: "Map")
        
        self.initLocationManager()
        self.initGoogleMaps()
    }
    
    // reload/update everything when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.refreshQuery()
        self.observeAllEvents()
    }
    
    // must be implemented. Determines whether a given event should be added to the map based on the filter
    internal func shouldAdd(_ event: Event) -> Bool {
        fatalError("MapController.shouldAdd not implemented")
    }
    
    internal func refreshQuery() {
       // override if needed
    }
    
    // respond to any changes in the database regarding events that satisfy this query
    private func observeAllEvents() {
        self.observeAddedEvents()
        self.observeChangedEvents()
        self.observeRemovedEvents()
    }
    
    // free database reference when view disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.events_query.removeAllObservers()
    }

}
