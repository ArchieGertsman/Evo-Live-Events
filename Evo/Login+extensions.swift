//
//  Login+handlers.swift
//  Evo
//
//  Created by Admin on 3/31/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

extension LoginController {
    
    /// go to registration
    
    @objc internal func openRegistrationPage() {
        let registration_controller = RegistrationController()
        self.present(registration_controller, animated: false, completion: nil)
    }
    
    @objc internal func openResetPasswordPage() {
        let reset_password_controller = ResetPasswordController()
        self.present(reset_password_controller, animated: false, completion: nil)
    }
    
    /// login
    
    @objc internal func handleLogin() {
        // if fields aren't empty then try to sign in
        if let email = email_text_field.text, let password = password_text_field.text,
            !email.isEmpty && !password.isEmpty
        {
            self.signIn(email: email, password: password)
        }
        else {
            self.showAlert(
                title: "Failed to log in",
                message: "All fields must be filled",
                acceptence_text: "Okay",
                cancel: false,
                completion: nil
            )
        }
    }
    
    private func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.showAlert(
                    title: "Failed to log in",
                    message: "Incorrect email or password",
                    acceptence_text: "Okay",
                    cancel: false,
                    completion: nil
                )
                return
            }
        })
    }
    
}

extension ResetPasswordController {
    
    @objc internal func dismissToLogin() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc internal func handlePasswordReset() {
        guard let email = email_text_field.text, !email.isEmpty else { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error == nil {
                self.showAlert(
                    title: "Reset Successful!",
                    message: "Your password reset link has been sent",
                    acceptence_text: "Okay",
                    cancel: false,
                    completion: nil
                )
            }
            else {
                self.showAlert(
                    title: "Failure to reset password",
                    message: "Please enter a valid email adderss",
                    acceptence_text: "Okay",
                    cancel: false,
                    completion: nil
                )
            }
        }
    }
}
