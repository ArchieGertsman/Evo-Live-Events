//
//  EventFeedController+extensions.swift
//  Evo
//
//  Created by Admin on 6/11/17.
//  Copyright © 2017 Evo. All rights reserved.
//
//import Firebase

import UIKit
import Firebase

extension EventFeedController {
    
    // when details button is clicked
    func showDetails(with event: Event) {
        
        if (self as? GroupController) != nil {
            self.showDetailsWithProfile(with: event)
        } else {
            event.gid != nil ?
                self.showDetailsWithGroup(with: event) :
                self.showDetailsWithProfile(with: event)
        }
        
    }
    
    private func showDetailsWithProfile(with event: Event) {
        if let _ = event.profile {
            print("open with profile")
            self.openDetailsController(event)
        }
        else {
            Profile.initProfile(with: event.uid) { profile in
                event.profile = profile
                self.openDetailsController(event)
            }
        }
    }

    private func showDetailsWithGroup(with event: Event) {
        if let _ = event.group {
            self.openDetailsController(event)
        }
        else {
            Group.initGroup(with: event.gid!) { group in
                event.group = group
                self.openDetailsController(event)
            }
        }
    }
    
    private func openDetailsController(_ event: Event) {
        let controller = EventFeedCellDetailsController(event)
        controller.viewController = self.viewController ?? self
        controller.modalPresentationStyle = .overFullScreen
        controller.view.alpha = 0.0
        
        (self.viewController ?? self).present(controller, animated: false) {
            UIView.animate(withDuration: 0.15) {
                controller.view.alpha = 1.0
            }
        }
        
    }
    
}

extension EventFeedController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5 // spacing between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if let group_datasource = self.datasource as? GroupDatasource, group_datasource.group.is_private {
            
            return CGSize(
                width: view.frame.width,
                height: !group_datasource.is_current_user_in_group ?
                    EventFeedFooter.large_private_height :
                    EventFeedFooter.small_private_height
            )
        }
        
        return CGSize(width: view.frame.width, height: EventFeedFooter.normal_height)
    }
    
}

extension EventFeedCellDetailsPopup {
    
    func fillProfileInformation(with profile: Profile) {
        self.name_label.text = profile.name
        
        if let image_url = profile.image_url {
            profile_image_view.kf.setImage(with: URL(string: image_url))
        } else {
            profile_image_view.image = #imageLiteral(resourceName: "default_user_image")
        }
    }
    
    func fillGroupInformation(with group: Group) {
        self.name_label.text = group.name
        
        if let image_url = group.image_url {
            profile_image_view.kf.setImage(with: URL(string: image_url))
        } else {
            profile_image_view.image = #imageLiteral(resourceName: "default_user_image")
        }
    }
    
    internal func load(with event: Event) {
        self.title_text_view.text = event.title  
        self.location_button.setTitle(event.place!.name, for: .normal)
        self.tag_label.text = event.tag.rawValue
        self.description_text_view.text = event.description
        self.ages_label.text = "Ages: \(event.ages.rawValue)"
        self.setTime()
        self.distance_label.text = "\(event.distance_from_me.map { String($0) } ?? "?") miles"
        
        // entity information is filled out by the delegating controller
    }
    
    private func setTime() {
        
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(self.event.time.start) || (self.event.state == .live || self.event.state == .upcoming) {
            formatter.dateFormat = "hh:mm a"
            self.time_label.text = "\(formatter.string(from: self.event.time.start)) - \(formatter.string(from: self.event.time.end))"
        }
        else {
            formatter.dateFormat = "MM/dd/yy"
            self.time_label.text = "\(formatter.string(from: self.event.time.start))"
        }
    }
    
    func estimatePopupViewSize(with event: Event) -> CGRect {
        let screen_width = UIScreen.main.bounds.size.width
        let screen_height = UIScreen.main.bounds.size.height
        let details_view_width = screen_width * 0.8
        let detials_view_x = (screen_width / 2) - (details_view_width / 2)
        
        // estimate details view rect based on attributes of its Event object
        let title_attributes = [NSAttributedStringKey.font: UIFont(size: 27)]
        let entity_name_attributes = [NSAttributedStringKey.font: UIFont(size: 17)]
        let description_attributes = [NSAttributedStringKey.font: UIFont(size: 15)]
        
        let estimated_title_frame = NSString(string: event.title).boundingRect(with: CGSize(width: details_view_width - 80, height: 1000), options: .usesLineFragmentOrigin, attributes: title_attributes, context: nil)
        
        let estimated_entity_name_frame = NSString(string: event.group?.name ?? event.profile?.name ?? "").boundingRect(with: CGSize(width: details_view_width / 2, height: 1000), options: .usesLineFragmentOrigin, attributes: entity_name_attributes, context: nil)
        
        let estimated_description_frame = NSString(string: event.description).boundingRect(with: CGSize(width: details_view_width - 20, height: 1000), options: .usesLineFragmentOrigin, attributes: description_attributes, context: nil)
        
        let details_view_height = (estimated_title_frame.height <= 54.0 ? estimated_title_frame.height : 54.0) + estimated_description_frame.height + estimated_entity_name_frame.height + 250
        let details_view_y = (screen_height / 2) - (details_view_height / 2)
        
        return CGRect(x: detials_view_x, y: details_view_y, width: details_view_width, height: details_view_height)
    }
    
    @objc internal func viewEntityPage(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            (self.delegate as? EventFeedCellDetailsPopupDelegate)?.viewEntityPage()
        }
        
    }
    
    @objc internal func getDirectionsToLocation() {
        // if google maps is available then proceed
        if UIApplication.shared.canOpenURL(URL(string: GOOGLE_MAPS_URL)!) {
            if let place_id = self.event.place?.placeID {
                UIApplication.shared.open(URL(string: GOOGLE_MAPS_URL_EXTENDED + place_id)!)
            }
        }
    }
    
    private func closeDetailsView(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            self.removeFromSuperview()
        }
    }
    
    @objc internal func removeEvent() {
        (self.delegate as? EventFeedCellDetailsController)?.showEventRemovalAlert(self.event.id, self.event.gid) { did_remove in
            if did_remove {
                self.removeFromSuperview()
                self.delegate?.close()
            }
        }
    }
}

private let GOOGLE_MAPS_URL = "https://www.google.com/maps/dir/?api=1"
private let GOOGLE_MAPS_URL_EXTENDED = "https://www.google.com/maps/dir/?api=1&destination=QVB&destination_place_id="

extension EventFeedCell {
    
    @objc internal func showDetailsHandler() {
        guard let controller = self.controller as? EventFeedController, let event = self.event else {
            print("could not retrieve cell's controller [FeedEventCell]")
            return
        }
        
        Analytics.logEvent("show_event_details", parameters: nil)
        
        controller.showDetails(with: event)
    }
    
    internal func load(with event: Event) {
        self.event = event
        
        for sv in self.subviews {
            sv.removeFromSuperview()
        }
        
        if event.is_first_in_time_group {
            let marker_time_mode = (self.controller as? EventFeedController)?.time_mode ?? .date
            
            self.addHourMarkerView(with: self.event.time.start, by: marker_time_mode)
            self.addSubviews(top_anchor: hour_marker_view!.bottomAnchor)
        }
        else {
            self.addSubviews(top_anchor: self.topAnchor)
        }
        
        self.setLabels()
    }
    
    private func setLabels() {
        self.background_image_view.image = UIImage(named: self.event.cell_background_name)
        title_label.text = self.event.title
        
        Event.getNumberOfAttendees(forEID: event.id) { num in
            DispatchQueue.main.async {
                self.going_count.text = String(num)
            }
        }
        
        switch event.state {
        case .live: self.state_label.text = "LIVE"
        case .ended: self.state_label.text = "FINISHED"
        case .upcoming: self.state_label.text = "UPCOMING"
        }
        
        switch event.state {
        case .live, .upcoming: self.going_count_label.text = "Going"
        case .ended: self.going_count_label.text = "Went"
        }

        let marker_time_mode = (self.controller as? EventFeedController)?.time_mode ?? .date
        
        switch marker_time_mode {
        case .hour: distance_label.text = "\(self.event.distance_from_me.map { String($0) } ?? "?") Miles"
        case .date:
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            distance_label.text = "\(formatter.string(from: self.event.time.start)) - \(formatter.string(from: self.event.time.end))"
        }
    }
    
    func addHourMarkerView(with date: Date, by mode: Time.Mode) {
        hour_marker_view = EventFeedTimeMarkerView(with: date, by: mode)
        
        hour_marker_view!.backgroundColor = .white
        hour_marker_view!.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(hour_marker_view!)
        
        hour_marker_view!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        hour_marker_view!.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        hour_marker_view!.heightAnchor.constraint(equalToConstant: EventFeedTimeMarkerView.height).isActive = true
        hour_marker_view!.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    func addSubviews(top_anchor: NSLayoutYAxisAnchor) {
        self.background_image_view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubviews()
        self.constrainBackgroundImage(top_anchor)
        self.constrainLabels(top_anchor)
        self.constrainGoingCount()
        self.constrainDetailsButton()
    }
    
    private func addSubviews() {
        self.addSubview(background_image_view)
        self.addSubview(title_label)
        self.addSubview(distance_label)
        self.addSubview(state_label)
        self.addSubview(going_count_label)
        self.addSubview(going_count)
        self.addSubview(details_button)
    }
    
    private func constrainBackgroundImage(_ top_anchor: NSLayoutYAxisAnchor) {
        self.background_image_view.topAnchor.constraint(equalTo: top_anchor).isActive = true
        self.background_image_view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.background_image_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.background_image_view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    private func constrainLabels(_ top_anchor: NSLayoutYAxisAnchor) {
        self.title_label.topAnchor.constraint(equalTo: top_anchor, constant: 20).isActive = true
        self.title_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.title_label.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        self.distance_label.topAnchor.constraint(equalTo: title_label.bottomAnchor, constant: 10).isActive = true
        self.distance_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.state_label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        self.state_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        
        self.going_count_label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        self.going_count_label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
    }
    
    private func constrainGoingCount() {
        self.going_count.centerXAnchor.constraint(equalTo: going_count_label.centerXAnchor).isActive = true
        self.going_count.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.going_count.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.going_count.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    private func constrainDetailsButton() {
        self.details_button.topAnchor.constraint(equalTo: distance_label.bottomAnchor, constant: 15).isActive = true
        self.details_button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.details_button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.details_button.widthAnchor.constraint(equalToConstant: (details_button.titleLabel?.intrinsicContentSize.width)! + 20).isActive = true
    }
    
    @objc internal func viewEventAttendees(gesture_recognizer: UIGestureRecognizer) {
        guard gesture_recognizer.state == .ended else { return }
        let controller = EventAttendeesListController(for: self.event)
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: controller, action: #selector(controller.dismissWithoutCompletionNormally))
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        let event_attendees_controller = UINavigationController(rootViewController: controller)
        self.controller?.present(event_attendees_controller, animated: true, completion: nil)
    }
    
}
