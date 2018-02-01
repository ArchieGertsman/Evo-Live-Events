//
//  AppDelegate.swift
//  Project
//
//  Created by Admin on 3/12/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UserNotifications
import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.createWindow()
        self.initLibs()
        self.setUpNotifications(application)
        self.setStyles(application)
    
        // I was trying to handle opening notifications from the lock screen but never got it to work
        /*if let payload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
            if let action = payload["click_action"] as? String {
                let action_components = action.components(separatedBy: " ")
                let controller_id = action_components[0]
                let entity_id = action_components[1]
                
                // set root view controller to be login controller and tell it to push the controller corresponding to the push notification
                self.window?.rootViewController = UINavigationController(rootViewController: LoginController())
                AppDelegate.pushViewController(controller_id, entity_id)
                
                return true
            }
        }*/
        
        // set root view controller to be login controller
        window?.rootViewController = UINavigationController(rootViewController: LoginController())
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        
        let status = CLLocationManager.authorizationStatus()
        let not_authorized = status == .notDetermined || status == .restricted || status == .denied
            || !CLLocationManager.locationServicesEnabled()
        
        // if location not enabled and current root view controller isn't login then set it to login
        if not_authorized && !(self.window?.rootViewController is LoginController) {
            self.window?.rootViewController = UINavigationController(rootViewController: LoginController())
        }
    }
    
    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    }
    
    private func initLibs() {
        IQKeyboardManager.sharedManager().enable = true
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyDYof-6Z_lcMAr2kCMoC9Rw8ZnlolL68Co")
        GMSPlacesClient.provideAPIKey("AIzaSyBX4-2U3YWK4JhsFh5XRK2HLd4lHgb0Af0")
    }
    
    private func setUpNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // print(granted ? "Notification access granted" : "Notification access not granted")
        }
        
        application.registerForRemoteNotifications()
    }
    
    private func setStyles(_ application: UIApplication) {
        application.statusBarStyle = .lightContent
        UIApplication.shared.statusBarStyle = .lightContent
        
        let searchBarTextAttributes: [String : AnyObject] = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white, NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes
    }
    
    // sets root controller to be the feed and shows the Evo overlay
    class func launchApplication() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = UINavigationController(rootViewController: MainEventFeedTabBarController(mode: .feed))
        UINavigationBar.initNavBar()
        EvoOverlay.display()
    }

}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        print("Push notification received: \(data)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("push notification:", userInfo)
        
        completionHandler(.newData)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    enum ControllerID: String {
        case profile = "profile"
        case request = "request"
        case invitation = "invitation"
        
    }
    
    struct NotificaitonData {
        var controller_id: ControllerID
        var entity_id: String
        
        init(action: String) {
            let action_components = action.components(separatedBy: " ")
            self.controller_id = ControllerID(rawValue: action_components[0])!
            self.entity_id = action_components[1]
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if let action = response.notification.request.content.userInfo["click_action"] as? String {
            let data = NotificaitonData(action: action)
            AppDelegate.pushViewController(with: data)
        }
        
        completionHandler()
    }
    
    // presents a view controller based on data from a push notification
    class func pushViewController(with data: NotificaitonData) {
        switch data.controller_id {
        case .profile: pushProfileController(id: data.entity_id)
        case .request: pushPendingRequestsController()
        case .invitation: pushEventInvitationsController()
        }
    }
    
    internal class func pushProfileController(id: String) {
        guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
        
        for controller in nc.viewControllers as Array {
            if controller.isKind(of: ProfileController.self) && (controller as! ProfileController).profile.id == id {
                if !tvc.isKind(of: EvoMenuController.self) {
                    tvc.dismiss(animated: true, completion: nil)
                }
                nc.popToViewController(controller, animated: true)
                return
            }
        }
        
        if !tvc.isKind(of: EvoMenuController.self) {
            tvc.dismiss(animated: true, completion: nil)
        }
        Profile.initProfile(with: id) { profile in
            if let profile = profile {
                nc.pushViewController(ProfileController(of: profile), animated: true)
            }
        }
    }
    
    internal class func pushPendingRequestsController() {
        guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
        
        for controller in nc.viewControllers as Array {
            if controller is PendingListController {
                if !tvc.isKind(of: EvoMenuController.self) {
                    tvc.dismiss(animated: true, completion: nil)
                }
                nc.popToViewController(controller, animated: true)
                return
            }
        }
        
        if !tvc.isKind(of: EvoMenuController.self) {
            tvc.dismiss(animated: true, completion: nil)
        }
        nc.pushViewController(PendingListController(), animated: true)
    }
    
    internal class func pushEventInvitationsController() {
        guard let nc = UIApplication.getNavigationController(), let tvc = UIApplication.getTopViewController() else { return }
        
        for controller in nc.viewControllers as Array {
            if controller is EventInvitationListController {
                if !tvc.isKind(of: EvoMenuController.self) {
                    tvc.dismiss(animated: true, completion: nil)
                }
                nc.popToViewController(controller, animated: true)
                return
            }
        }
        
        if !tvc.isKind(of: EvoMenuController.self) {
            tvc.dismiss(animated: true, completion: nil)
        }
        nc.pushViewController(EventInvitationListController(), animated: true)
    }
    
}


