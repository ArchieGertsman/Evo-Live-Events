//
//  MainEventFeedTabBarController.swift
//  Evo
//
//  Created by Admin on 8/20/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

/* Tab bar controller which contains either event feed tabs or event map tabs. Tabs can be public or my crowds */
class MainEventFeedTabBarController: EvoTabBarController {
    
    let display_mode: DisplayMode
    let location_manager = CLLocationManager()
    var filter: Filter?
    
    enum DisplayMode {
        case feed
        case map
    }
    
    required init(mode: DisplayMode) {
        self.display_mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEvoStyle(title: self.display_mode == .feed ? "Feed" : "Map")
        self.initLocation()
        
        self.setTabs()
    }
    
    private func setTabs() {
        switch self.display_mode {
        case .feed:
            self.viewControllers = [
                self.getSetUpController(from: PublicEventFeedController(), tabTitle: "Public"),
                self.getSetUpController(from: MyCrowdsEventFeedController(), tabTitle: "My Crowds")
            ]
        case .map:
            self.viewControllers = [
                self.getSetUpController(from: PublicEventMapController(), tabTitle: "Public"),
                self.getSetUpController(from: MyCrowdsEventMapController(), tabTitle: "My Crowds")
            ]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func setUpNavigationBarItems() {
        // create event button
        let create_button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        create_button.setBackgroundImage(#imageLiteral(resourceName: "feed_create_emblem").withRenderingMode(.alwaysTemplate), for: .normal)
        create_button.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: create_button)
        
        // filter button
        let filter_button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        filter_button.setBackgroundImage(#imageLiteral(resourceName: "filter_emblem").withRenderingMode(.alwaysTemplate), for: .normal)
        filter_button.addTarget(self, action: #selector(openFilterController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: filter_button)
    }
    
    // when create event button is tapped
    @objc func createEvent() {
        guard let nc = UIApplication.getNavigationController() else { return }
        self.navigationItem.rightBarButtonItem?.isEnabled = false // prevent spamming the button
        
        var users_dict = Dictionary<String, String>() // maps a user's name to a user id
        var groups_dict = Dictionary<String, String>() // maps a group's name to a group id
        
        let dispatch_group = DispatchGroup()
        
        dispatch_group.enter()
        self.getFollowings { my_users_dict in
            users_dict = my_users_dict
            dispatch_group.leave()
        }
        
        dispatch_group.enter()
        self.getGroups { my_groups_dict in
            groups_dict = my_groups_dict
            dispatch_group.leave()
        }
        
        dispatch_group.notify(queue: .main) {
            nc.pushViewController(CreateEventController(users_dict, groups_dict), animated: true)
        }
        
    }
    
    private func getFollowings(completion: @escaping (Dictionary<String, String>) -> Void) {
        let dispatch_group = DispatchGroup()
        var users_dict = Dictionary<String, String>()
        
        dispatch_group.enter()
        Database.database().reference().child(DBChildren.user_followings).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { snapshot in
            if let uids_dict = snapshot.value as? [String : AnyObject] {
                let uids = Array(uids_dict.keys)
                
                dispatch_group.enter()
                Profile.initProfiles(with: uids) { profiles in
                    
                    for profile in profiles {
                        users_dict[profile.name] = profile.id
                    }
                    
                    dispatch_group.leave()
                }
            }
            dispatch_group.leave()
        }
        
        dispatch_group.notify(queue: .main) {
            completion(users_dict)
        }
    }
    
    private func getGroups(completion: @escaping (Dictionary<String, String>) -> Void) {
        let dispatch_group = DispatchGroup()
        var groups_dict = Dictionary<String, String>()
        
        dispatch_group.enter()
        Database.database().reference().child(DBChildren.user_groups).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { snapshot in
            if let gids_dict = snapshot.value as? [String : AnyObject] {
                let gids = Array(gids_dict.keys)
                
                dispatch_group.enter()
                Group.initGroups(with: gids) { groups in
                    
                    for group in groups {
                        groups_dict[group.name] = group.id
                    }
                    
                    dispatch_group.leave()
                }
            }
            dispatch_group.leave()
        }
        
        dispatch_group.notify(queue: .main) {
            completion(groups_dict)
        }
    }
    
    // when filter button is tapped
    @objc func openFilterController() {
        let controller = self.filter != nil ? EventFeedFilterController(with: self.filter!) : EventFeedFilterController()
        controller.delegate = self
        let filter_controller = UINavigationController(rootViewController: controller)
        filter_controller.modalPresentationStyle = .overFullScreen
        filter_controller.modalTransitionStyle = .crossDissolve
        self.present(filter_controller, animated: true, completion: nil)
    }
    
    func initLocation() {
        // Ask for Authorisation from the User.
        self.location_manager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.location_manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            location_manager.delegate = self
            location_manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            location_manager.startMonitoringSignificantLocationChanges()
            location_manager.startUpdatingLocation()
        }
    }

}

extension MainEventFeedTabBarController: CLLocationManagerDelegate {
    
    // keep track of changes in user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _ = MapController.current_location else {
            MapController.current_location = manager.location!
            return
        }
        
        if MapController.current_location != manager.location! {
            MapController.current_location = manager.location!
        }
    }
    
}

extension MainEventFeedTabBarController: EventFeedFilterControllerDelegate {
    
    func updateFilter(with filter: Filter?) {
        self.filter = filter
        for nc in self.viewControllers! {
            ((nc as! UINavigationController).viewControllers[0] as! EventFeedController).handleRefresh()
        }
    }
    
    func changeFilterButtonColor(to color: UIColor) {
        self.navigationItem.leftBarButtonItem?.customView?.tintColor = color
    }
    
}
