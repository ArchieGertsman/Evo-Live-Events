//
//  MapController+handlers.swift
//  Evo
//
//  Created by Admin on 5/24/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import Firebase

private func randomDouble(min: Double, max: Double) -> Double {
    return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
}

extension MapController {
    
    private func checkIfMutlipleCoordinates(position: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var ret_pos = position
        
        let matches = self.markers.filter { position == $0.position }
        
        if !matches.isEmpty {
            let variation = (randomDouble(min: 0.0, max: 2.0) - 0.5) / 1500
            ret_pos.latitude += variation
            ret_pos.longitude += variation
            
            return checkIfMutlipleCoordinates(position: ret_pos)
        }
        
        return ret_pos
    }
    
    private func addMarker(with event: Event) {
        guard let coordinate = event.place?.coordinate else {
            print("No coordinate in event [Map]")
            return
        }
        
        let marker = GMSMarker(position: self.checkIfMutlipleCoordinates(position: coordinate))
        marker.iconView = MapController.marker_view
        marker.userData = event
        marker.map = self.google_maps_view
        
        self.markers.append(marker)
    }
    
    private func addMarkers(with events: [Event]) {
        for event in events {
            self.addMarker(with: event)
        }
    }
    
    internal func observeAddedEvents() {
        self.events_query.observe(.childAdded, with: { (snapshot) in
            if let event = Caches.events.object(forKey: snapshot.key as Caches.EventID), self.shouldAdd(event) {
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
    
    internal func observeChangedEvents() {
        self.events_query.observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                self.changeEvent(withDict: dictionary)
            }
            else {
                self.changeEvent(withID: snapshot.key)
            }
        })
    }
    
    internal func observeRemovedEvents() {
        self.events_query.observe(.childRemoved, with: { (snapshot) in
            if let event = Caches.events.object(forKey: snapshot.key as Caches.EventID) {
                if let i = self.markers.index(where: { ($0.userData as! Event).id == event.id }) {
                    self.markers.remove(at: i)
                    Caches.events.removeObject(forKey: event.id as Caches.EventID)
                }
            }
        })
    }
    
    internal func initLocationManager() {
        location_manager = CLLocationManager()
        location_manager.delegate = self
        location_manager.requestWhenInUseAuthorization()
        location_manager.startUpdatingLocation()
        location_manager.startMonitoringSignificantLocationChanges()
    }
    
    internal func initGoogleMaps() {
        self.google_maps_view.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.google_maps_view.delegate = self
        self.google_maps_view.isMyLocationEnabled = true
        self.google_maps_view.settings.myLocationButton = true
        self.google_maps_view.frame = view.frame
        view.addSubview(self.google_maps_view)
    }

}

// Helper functions
extension MapController {
    
    internal func add(_ event: Event) {
        if !self.markers.contains { ($0.userData as! Event).id == event.id } {
            self.addMarker(with: event)
        }
    }
    
    internal func addEvent(withDict dict: [String: AnyObject]) {
        Event.load(with: dict) { event in
            if let event = event, self.shouldAdd(event) {
                self.add(event)
            }
        }
    }
    
    internal func addEvent(withID id: String) {
        Event.load(withID: id) { event in
            if let event = event, self.shouldAdd(event) {
                self.add(event)
            }
        }
    }
    
    private func change(_ event: Event) {
        if let i = self.markers.index(where: { ($0.userData as! Event).id == event.id }) {
            self.markers[i].userData = event
            Caches.events.setObject(event, forKey: event.id as Caches.EventID)
        }
    }
    
    internal func changeEvent(withDict dict: [String: AnyObject]) {
        Event.load(with: dict) { event in
            if let event = event, event.accessibility == .public_ {
                self.change(event)
            }
        }
    }
    
    internal func changeEvent(withID id: String) {
        Event.load(withID: id) { event in
            if let event = event, event.accessibility == .public_ {
                self.change(event)
            }
        }
    }
    
}

extension MapController: GMSMapViewDelegate, CLLocationManagerDelegate {
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera = GMSCameraPosition.camera(withLatitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!, zoom: 17.0)
        
        self.google_maps_view.animate(to: camera)
        self.location_manager.stopUpdatingLocation()
    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.google_maps_view.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.google_maps_view.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let i = self.markers.index(of: marker) {
            self.showDetails(with: self.markers[i].userData as! Event)
        }
        return true
    }
}
