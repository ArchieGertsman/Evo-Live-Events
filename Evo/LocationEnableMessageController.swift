//
//  LocationEnableMessageController.swift
//  Evo
//
//  Created by Admin on 11/2/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LocationEnableMessageController: UIViewController {
    
    let location_manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create "Back to Login" button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back to Login", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backToLogin))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        // start observing locatioan status when application opens from background
        NotificationCenter.default.addObserver(self, selector: #selector(self.observeLocationStatus), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // make nav bar clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        self.view.addSubview(self.background_view)
        self.view.addSubview(self.message_label)
        
        self.background_view.frame = self.view.bounds
        
        self.message_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.message_label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.message_label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        self.message_label.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        
        // request location authorization
        self.location_manager.delegate = self
        self.location_manager.requestAlwaysAuthorization()
        self.location_manager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func backToLogin() {
        // log out and head back to login page
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func observeLocationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                AppDelegate.launchApplication()
            default:
                self.location_manager.requestAlwaysAuthorization()
                self.location_manager.requestWhenInUseAuthorization()
            }
        }
    }
    
    let message_label: UILabel = {
        let label = UILabel()
        label.text = "In order to use Evo, please enable location services in\nSettings → Privacy → Location Services → Evo"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(size: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let background_view: UIImageView = {
        let image_view = UIImageView()
        image_view.image = #imageLiteral(resourceName: "blue_gradient_background")
        return image_view
    }()

}

extension LocationEnableMessageController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            AppDelegate.launchApplication()
        default: break
        }
    }
    
}
