//
//  SettingsController.swift
//  Evo
//
//  Created by Admin on 7/2/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

var default_event_radius: UInt? {
    get {
        return UserDefaults.standard.value(forKey: "default-event-radius") as? UInt
    }
    set(new_val) {
        UserDefaults.standard.setValue(new_val, forKey: "default-event-radius")
        UserDefaults.standard.synchronize()
    }
}

class SettingsController: UITableViewController {
    
    let distance_slider_cell = UITableViewCell()
    let pending_requests_cell = UITableViewCell()
    let event_invitations_cell = UITableViewCell()
    let bug_reporting_cell = UITableViewCell()
    let terms_conditions_cell = UITableViewCell()
    let privacy_cell = UITableViewCell()
    let logout_cell = UITableViewCell()
    let delete_account_cell = UITableViewCell()
    
    var distance_slider = CustomUISlider()
    var pending_request_label = UILabel()
    var event_invitations_label = UILabel()
    var bug_reporting_label = UILabel()
    var terms_conditions_label = UILabel()
    var privacy_label = UILabel()
    var logout_label = UILabel()
    var delete_account_label = UILabel()
    
    required init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        // set the title
        self.initEvoStyle(title: "Settings")
        
        // row 0
        self.distance_slider_cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.distance_slider_cell.selectionStyle = .none
        
        // self.distance_slider = CustomUISlider(frame: self.distance_slider_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.distance_slider = CustomUISlider()
        self.distance_slider.delegate = self
        self.distance_slider.translatesAutoresizingMaskIntoConstraints = false
        self.distance_slider.label_color = .darkGray
        if let default_radius = default_event_radius {
            self.distance_slider.distance = default_radius
        }
        else {
            default_event_radius = 20
        }
        
        self.distance_slider_cell.addSubview(self.distance_slider)
        
        self.distance_slider.centerXAnchor.constraint(equalTo: self.distance_slider_cell.centerXAnchor).isActive = true
        self.distance_slider.centerYAnchor.constraint(equalTo: self.distance_slider_cell.centerYAnchor, constant: -8).isActive = true
        self.distance_slider.widthAnchor.constraint(equalTo: self.distance_slider_cell.widthAnchor, constant: -40).isActive = true
        self.distance_slider.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        // row 0
        self.pending_requests_cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.pending_requests_cell.accessoryType = .disclosureIndicator
        
        self.pending_request_label = UILabel(frame: self.pending_requests_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.pending_request_label.text = "Group Pending Requests"
        self.pending_request_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.pending_request_label.textColor = .EVO_text_gray
        
        self.pending_requests_cell.addSubview(self.pending_request_label)
        
        // row 1
        self.event_invitations_cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.event_invitations_cell.accessoryType = .disclosureIndicator
        
        self.event_invitations_label = UILabel(frame: self.event_invitations_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.event_invitations_label.text = "Event Invitations"
        self.event_invitations_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.event_invitations_label.textColor = .EVO_text_gray
        
        self.event_invitations_cell.addSubview(self.event_invitations_label)
        
        // row 2
        self.bug_reporting_cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.bug_reporting_cell.accessoryType = .disclosureIndicator
        
        self.bug_reporting_label = UILabel(frame: self.bug_reporting_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.bug_reporting_label.text = "Report a Bug/Issue"
        self.bug_reporting_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.bug_reporting_label.textColor = .EVO_text_gray
        
        self.bug_reporting_cell.addSubview(self.bug_reporting_label)
        
        // row 3
        self.terms_conditions_cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.terms_conditions_cell.accessoryType = .disclosureIndicator
        
        self.terms_conditions_label = UILabel(frame: self.terms_conditions_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.terms_conditions_label.text = "Terms and Conditions"
        self.terms_conditions_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.terms_conditions_label.textColor = .EVO_text_gray
        
        self.terms_conditions_cell.addSubview(self.terms_conditions_label)
        
        // row 4
        self.privacy_cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.privacy_cell.accessoryType = .disclosureIndicator
        
        self.privacy_label = UILabel(frame: self.privacy_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.privacy_label.text = "Privacy"
        self.privacy_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.privacy_label.textColor = .EVO_text_gray
        
        self.privacy_cell.addSubview(self.privacy_label)
        
        // logout
        
        self.logout_cell.backgroundColor = .EVO_blue
        self.logout_cell.accessoryType = .disclosureIndicator
        
        self.logout_label = UILabel(frame: self.logout_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.logout_label.text = "Log Out"
        self.logout_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.logout_label.textColor = .white
        
        self.logout_cell.addSubview(self.logout_label)
        
        // delete account
        
        self.delete_account_cell.backgroundColor = UIColor(r: 215, g: 0, b: 0)
        self.delete_account_cell.accessoryType = .disclosureIndicator
        
        self.delete_account_label = UILabel(frame: self.delete_account_cell.contentView.bounds.insetBy(dx: 15, dy: 0))
        self.delete_account_label.text = "Delete Account"
        self.delete_account_label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        self.delete_account_label.textColor = .white
        
        self.delete_account_cell.addSubview(self.delete_account_label)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let handle_view = self.distance_slider.subviews.last as? UIImageView {
            self.distance_slider.addDistanceLabel(position: .under, handle_view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addBadges()
    }
    
    var requests_badge: NotificationBadge?
    var invitations_badge: NotificationBadge?
    
    func addRequestsBadge() {
        PendingRequest.getNumberOfRequests(forUID: Auth.auth().currentUser!.uid) { num in
            guard num > 0 else { self.requests_badge?.removeFromSuperview(); return }
            
            self.requests_badge = NotificationBadge(num: num)
            self.requests_badge?.translatesAutoresizingMaskIntoConstraints = false
            
            DispatchQueue.main.async {
                self.pending_requests_cell.addSubview(self.requests_badge!)
                
                self.requests_badge?.centerYAnchor.constraint(equalTo: self.pending_requests_cell.centerYAnchor).isActive = true
                self.requests_badge?.rightAnchor.constraint(equalTo: self.pending_requests_cell.rightAnchor, constant: -40).isActive = true
                self.requests_badge?.widthAnchor.constraint(equalToConstant: self.requests_badge!.diameter).isActive = true
                self.requests_badge?.heightAnchor.constraint(equalToConstant: self.requests_badge!.diameter).isActive = true
            }
        }
    }
    
    func addInvitationsBadge() {
        Event.getNumberOfInvitations(forUID: Auth.auth().currentUser!.uid) { num in
            guard num > 0 else { self.invitations_badge?.removeFromSuperview(); return }
            
            self.invitations_badge = NotificationBadge(num: num)
            self.invitations_badge?.translatesAutoresizingMaskIntoConstraints = false
            
            DispatchQueue.main.async {
                self.event_invitations_cell.addSubview(self.invitations_badge!)
                
                self.invitations_badge?.centerYAnchor.constraint(equalTo: self.event_invitations_cell.centerYAnchor).isActive = true
                self.invitations_badge?.rightAnchor.constraint(equalTo: self.event_invitations_cell.rightAnchor, constant: -40).isActive = true
                self.invitations_badge?.widthAnchor.constraint(equalToConstant: self.invitations_badge!.diameter).isActive = true
                self.invitations_badge?.heightAnchor.constraint(equalToConstant: self.invitations_badge!.diameter).isActive = true
            }
        }
    }
    
    func addBadges() {
        self.addRequestsBadge()
        self.addInvitationsBadge()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 6
        default: fatalError("Unknown row in section 0")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: return self.distance_slider_cell
        case 1:
            switch indexPath.row {
            case 0: return self.pending_requests_cell
            case 1: return self.event_invitations_cell
            case 2: return self.bug_reporting_cell
            case 3: return self.terms_conditions_cell
            case 4: return self.privacy_cell
            case 5: return self.logout_cell
            default: fatalError("Unknown row in section 0")
            }
        default: fatalError("Unknown section")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0: break
        case 1:
            switch(indexPath.row) {
            case 0: self.openPendingRequestPage()
            case 1: self.openEventInvitationsPage()
            case 2: self.openBrowserPage(toURL: "https://goo.gl/forms/lPKfHTkVyWhytSO03") // report a bug
            case 3: self.openBrowserPage(toURL: "https://www.google.com") // terms and conditions
            case 4: self.openBrowserPage(toURL: "https://www.google.com") // privacy
            case 5: self.handleLogout()
            default: fatalError("Unknown row in section 0")
            }
        default: fatalError("Unknown section")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 40
        case 1: return 20
        default: fatalError("Unknown section")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 20
        case 1: return 5
        default: fatalError("Unknown section")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Default Event Radius (Miles)"
        case 1: return "General"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 68.0
        default: return 44.0
        }
    }
    
    func openPendingRequestPage() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: PendingListController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                return
            }
        }
        
        self.navigationController!.pushViewController(PendingListController(), animated: true)
    }
    
    func openEventInvitationsPage() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: EventInvitationListController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                return
            }
        }
        
        self.navigationController!.pushViewController(EventInvitationListController(), animated: true)
    }
    
    internal func openBrowserPage(toURL url_str: String) {
        let url = URL(string: url_str)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            //self.navigationController!.popToRootViewController(animated: true)
            guard let window = UIApplication.shared.keyWindow else { return }
            window.rootViewController = UINavigationController(rootViewController: LoginController())
            
        } catch let logoutError {
            print(logoutError)
        }
    }
    
}

extension SettingsController: CustomUISliderDelegate {
    func didChange(value: UInt) {
        if let default_value = default_event_radius {
            if value != default_value {
                default_event_radius = value
            }
        }
    }
}

