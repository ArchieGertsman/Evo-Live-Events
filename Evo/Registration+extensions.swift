//
//  Registration+extensions.swift
//  Evo
//
//  Created by Admin on 6/11/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

extension RegistrationController {
    
    @objc internal func openLoginPage() {
        self.dismiss(animated: false, completion: nil)
    }
    
    /// registration
    
    @objc internal func handleRegistration() {
        // if fields aren't empty, then try to create account
        
        if let name = name_text_field.text, !name.isEmpty,
            let email = email_text_field.text, !email.isEmpty,
            let password = password_text_field.text, !password.isEmpty,
            let password_confirmation = password_confirmation_text_field.text, !password_confirmation.isEmpty,
            password_confirmation == password
        {
                self.createUser(name: name, email: email, password: password)
                Analytics.logEvent("create_user", parameters: nil)
        }
        else {
            self.showAlert(
                title: "Failed to create account",
                message: "All fields must be filled",
                acceptence_text: "Okay",
                cancel: false,
                completion: nil
            )
        }
        
    }
    
    private func createUser(name: String, email: String, password: String) {
        // if passwords don't match then error
        guard let password_text = self.password_text_field.text,
            let password_confirmation_text = self.password_text_field.text,
            password_text == password_confirmation_text
            else {
                self.showAlert(
                    title: "Failed to create account",
                    message: "Passwords do not match",
                    acceptence_text: "Okay",
                    cancel: false,
                    completion: nil
                )
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user: User?, error) in
            
            guard error != nil, let uid = user?.uid else {
                self.showAlert(
                    title: "Failed to create account",
                    message: error?.localizedDescription ?? "An error has occurred",
                    acceptence_text: "Okay",
                    cancel: false,
                    completion: nil
                )
                return
            }
            
            if let user = user {
                self.sendNameChangeRequest(user, name)
            }
            
            // successfully authenticated
            self.putAccountDataIntoFirebase(uid, name, email)
        })
    }
    
    private func sendNameChangeRequest(_ user: User, _ name: String) {
        let change_request = user.createProfileChangeRequest()
        change_request.displayName = name // displayName not set automatically, so do it manually
        change_request.commitChanges { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func putAccountDataIntoFirebase(_ uid: String, _ name: String, _ email: String) {
        let values = [
            DBChildren.User.name: name,
            DBChildren.User.email: email,
            DBChildren.User.id: uid
        ] as [String : Any]
        
        Database.database().reference().child(DBChildren.users).child(uid).updateChildValues(values) { error, ref in
            
            if let error = error {
                self.showAlert(
                    title: "Failed to create account",
                    message: error.localizedDescription,
                    acceptence_text: "Okay",
                    cancel: false,
                    completion: nil
                )
                return
            }
            
            // successfully saved into database; remove login/registration pages
            self.launchApplication()
        }
    }
    
    private func launchApplication() {
        // remove the registration screen and change the root controller to be the main ViewController
        self.dismiss(animated: false, completion: {
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    // location not enabled
                    self.navigationController?.pushViewController(LocationEnableMessageController(), animated: true)
                case .authorizedAlways, .authorizedWhenInUse:
                    // proceed to feed
                    AppDelegate.launchApplication()
                }
            } else {
                // location not enabled
                self.navigationController?.pushViewController(LocationEnableMessageController(), animated: true)
            }
        })
    }
    
}
