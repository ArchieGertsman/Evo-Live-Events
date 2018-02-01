//
//  CreateEvent+handlers.swift
//  Evo
//
//  Created by Admin on 4/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Firebase
import GooglePlaces

extension CreateEventController {
    
    @objc internal func createEvent() {
        
        guard let title = name_text_view.text, title != name_text_view.placeholder,
            let description = description_text_view.text, description != description_text_view.placeholder,
            let location = location_label.text, location != CreateEventController.default_location_text, location != CreateEventController.location_error_message,
            let start_time = starttime_text_field.text, start_time != starttime_text_field.placeholder,
            let end_time = endtime_text_field.text, end_time != endtime_text_field.placeholder,
            let tag = tags_text_field.text, !tag.isEmpty,
            let ages = ages_text_field.text, !ages.isEmpty
        else {
            self.showAlert(
                title: "Failed to create event",
                message: "All fields must be filled",
                acceptence_text: "Okay",
                cancel: false,
                completion: nil
            )
            return
        }
        
        if self.place == nil {
            self.showAlert(
                title: "Failed to create event",
                message: "Error reading location",
                acceptence_text: "Okay",
                cancel: false,
                completion: nil
            )
            return
        }
        
        guard let start_unix_time = getUnixTimeFrom(string: start_time),
            let end_unix_time = getUnixTimeFrom(string: end_time) else { return }
        
        (self.event_creation_method_selection_view.selected_creation_method == .group ?
            self.createGroupEvent : self.addNormalEventToFB)(title, description, start_unix_time, end_unix_time, tag, ages)
    }
    
    private func createGroupEvent(_ title: String, _ description: String, _ start_time: TimeInterval, _ end_time: TimeInterval, _ tag: String, _ ages: String) {
        if let invitation_token_view = self.invitation_token_view {
            // if this is a group event being created in the standard create event page, then initialize the Group object
            let group_token = invitation_token_view.token_view.getAllTokens()[0]
            let gid = self.invitation_token_view!.groups_dict[group_token.displayText]!
            
            Group.initGroup(with: gid) { group in
                if let group = group {
                    self.group = group
                    self.addGroupEventToFB(title, description, start_time, end_time, tag, ages)
                }
            }
        }
        else {
            // group even being created directly from group's page
            self.addGroupEventToFB(title, description, start_time, end_time, tag, ages)
        }
    }
    
    // the following two functions only differ by one line, but the order of the lines matters so idk how to make this cleaner
    
    private func addGroupEventToFB(_ title: String, _ description: String, _ start_time: TimeInterval, _ end_time: TimeInterval, _ tag: String, _ ages: String) {
        self.getEventDict(title, description, start_time, end_time, tag, ages) { event in
            self.addEventToFirebase(event)
            self.logEventCreation(start_time, end_time, tag)
            self.addEventToGroupMembersMyCrowds(event[DBChildren.Event.id]! as! String)
            self.removeController()
        }
    }
    
    private func addNormalEventToFB(_ title: String, _ description: String, _ start_time: TimeInterval, _ end_time: TimeInterval, _ tag: String, _ ages: String) {
        self.getEventDict(title, description, start_time, end_time, tag, ages) { event in
            self.addEventToFirebase(event)
            self.logEventCreation(start_time, end_time, tag)
            self.inviteUsersToEvent(event[DBChildren.Event.id]! as! String)
            self.removeController()
        }
    }
    
    private func logEventCreation(_ start_time: TimeInterval, _ end_time: TimeInterval, _ tag: String) {
        let method = self.event_creation_method_selection_view.selected_creation_method
        Analytics.logEvent("create_event", parameters: [
            "type" : method.rawValue,
            "start_time" : hourOfDay(fromTimeInterval: start_time),
            "end_time" : hourOfDay(fromTimeInterval: end_time),
            "tag" : tag
        ])
    }
    
    private func getUnixTimeFrom(string: String) -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd h:mm a"
        
        guard let starttime_date = formatter.date(from: string) else { return nil }
        
        let calendar = Calendar.current
        let current_date = Date()
        
        var start_components = calendar.dateComponents([.month, .day, .hour, .minute], from: starttime_date)
        start_components.year = calendar.component(.year, from: current_date)
        
        let gregorian = Calendar(identifier: .gregorian)
        guard let start = gregorian.date(from: start_components) else { return nil }
        
        return start.timeIntervalSince1970
    }
    
    private func getEventID() -> String {
        var key: String
        let ref = Database.database().reference()
        
        if let group = self.group, group.is_private {
            key = ref.child(DBChildren.group_events).child(group.id).childByAutoId().key
        } else {
            key = ref.child(DBChildren.events).childByAutoId().key
        }
        
        return key
    }
    
    private func getEventDict(_ title: String, _ description: String, _ start_time: TimeInterval, _ end_time: TimeInterval, _ tag: String, _ ages: String, completion: @escaping ([String : Any]) -> Void) {
        
        let method = self.event_creation_method_selection_view.selected_creation_method
        
        let accessibility: Event.Accessibility
        
        switch method {
        case .public_: accessibility = .public_
        case .my_crowds: accessibility = .my_crowds
        case .invite_only: accessibility = .invite_only
        case .group: accessibility = self.group!.is_private ? .private_group : .public_
        }
        
        getLocationName(fromCoord: self.place!.coordinate) { raw_location in
            var event = [
                DBChildren.Event.title:                 title,
                DBChildren.Event.description:           description,
                DBChildren.Event.place_id:              self.place!.placeID,
                DBChildren.Event.start_time:            start_time,
                DBChildren.Event.end_time:              end_time,
                DBChildren.Event.tag:                   tag,
                DBChildren.Event.ages:                  ages,
                DBChildren.Event.uid:                   Auth.auth().currentUser!.uid,
                DBChildren.Event.id:                    self.getEventID(),
                DBChildren.Event.cell_background_name:  EventCellBackgroundGenerator.getImageName(ofType: tag),
                DBChildren.Event.accessibility:         accessibility.rawValue
            ] as [String : Any]
            
            if let rl = raw_location {
                event[DBChildren.Event.raw_location] = rl
            }
            
            if let group = self.group {
                event[DBChildren.Event.gid] = group.id
            }
            
            completion(event)
        }
    }
    
    private func addEventToFirebase(_ event: [String : Any]) {
        let eid = event[DBChildren.Event.id] as! String
        
        // add event data to main events child
        var child_updates: [String : Any] = ["/\(DBChildren.events)/\(eid)": event]
        
        // add to group
        if let group = self.group {
            child_updates["/\(DBChildren.group_events)/\(group.id)/\(eid)/"] = true
        }
        
        Database.database().reference().updateChildValues(child_updates)
        
        Event.attend(Auth.auth().currentUser!.uid, eid)
    }
    
    private func addEventToGroupMembersMyCrowds(_ eid: String) {
        guard let group = self.group else { return }
        
        Group.getMemberIDs(group.id) { uids in
            for uid in uids {
                Event.addToMyCrowds(eid, uid)
            }
        }
    }
    
    private func inviteUsersToEvent(_ eid: String) {
        
        guard let invitation_token_view = self.invitation_token_view else { return }
        
        let method = self.event_creation_method_selection_view.selected_creation_method
        
        if method == .public_ {
            // put event into all of followers' my crowds if public event
            Profile.getFollowersUIDs(Auth.auth().currentUser!.uid) { uids in
                for uid in uids {
                    Event.addToMyCrowds(eid, uid)
                }
            }
        }
        
        let tokens = invitation_token_view.token_view.getAllTokens()
        for token in tokens {
            let uid = self.invitation_token_view!.users_dict[token.displayText]!
            Event.invite(uid, eid)
        }
    }
    
    private func removeController() {
        self.showAlert(title: "Success!", message: "Your event has been created", acceptence_text: "Okay", cancel: false) { alert in
            // if this is a group event, pop back to group page. Else, pop back to main event feed.
            if let _ = self.group {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                _ = self.navigationController?.popToRootViewController(animated: true)
            }            
        }
        
    }
    
    @objc internal func chooseLocation() {
        
        guard let coord = MapController.current_location?.coordinate else {
            self.location_label.text = CreateEventController.location_error_message
            return
        }
        
        let autocomplete_controller = GMSAutocompleteViewController()
        autocomplete_controller.delegate = self
        autocomplete_controller.modalPresentationStyle = .overCurrentContext
        
        let north_east = locationWithBearing(bearing: Double.pi / 4, distanceMeters: meters(fromMiles: 4), origin: coord)
        let south_west = locationWithBearing(bearing: 5 * Double.pi / 4, distanceMeters: meters(fromMiles: 4), origin: coord)
        
        autocomplete_controller.autocompleteBounds = GMSCoordinateBounds(coordinate: north_east, coordinate: south_west)
 
        self.present(autocomplete_controller, animated: true, completion: nil)
    }
    
    @objc internal func handleStarttimePicker(sender: UIDatePicker) {
        self.start_time = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm a"
        starttime_text_field.text = "\(dateFormatter.string(from: sender.date))"
        self.addDatePickerToEndTime(withStartDate: sender.date)
        
        if self.endtime_text_field.text != self.endtime_text_field.placeholder {
            self.endtime_text_field.text = "\(dateFormatter.string(from: (endtime_text_field.inputView as! UIDatePicker).minimumDate!))"
        }
    }
    
    private func addDatePickerToEndTime(withStartDate start_date: Date) {
        let date_picker = UIDatePicker()
        
        date_picker.minimumDate = Calendar.current.date(byAdding: .minute, value: 1, to: start_date)
        date_picker.maximumDate = Calendar.current.date(byAdding: .hour, value: 18, to: Date())
        
        date_picker.datePickerMode = .dateAndTime
        date_picker.addTarget(self, action: #selector(handleEndtimePicker(sender:)), for: .valueChanged)
        endtime_text_field.inputView = date_picker
    }
    
    @objc internal func handleEndtimePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm a"
        endtime_text_field.text = "\(dateFormatter.string(from: sender.date))"
    }
    
}

func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    let distRadians = distanceMeters / (6372797.6) // earth radius in meters
    
    let lat1 = origin.latitude * Double.pi / 180
    let lon1 = origin.longitude * Double.pi / 180
    
    let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
    let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
    
    return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
}

func meters(fromMiles miles: Double) -> Double {
    return miles * 1609.34
}

private func hourOfDay(fromTimeInterval time: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: time)
    let formatter = DateFormatter()
    formatter.dateFormat = "h a"
    return formatter.string(from: date)
}

extension CreateEventController {
    /* text view mods */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.EVO_text_light_gray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textView.placeholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case self.name_text_view:
            self.name_height_constraint.isActive = false
            
            let name_attributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans", size: 15)!]
            
            let screen_width = UIScreen.main.bounds.size.width
            let name_view_width = screen_width - 60
            
            let estimated_name_frame = NSString(string: textView.text).boundingRect(with: CGSize(width: name_view_width, height: 1000), options: .usesLineFragmentOrigin, attributes: name_attributes, context: nil)
            
            self.name_height_constraint = self.name_text_view.heightAnchor.constraint(equalToConstant: estimated_name_frame.height + 20)
            self.name_height_constraint.isActive = true
            
            scroll_view.contentSize = CGSize(width: self.view.frame.width, height: create_button.frame.maxY + 100)
            
        case self.description_text_view:
            self.description_height_constraint.isActive = false
            
            let description_attributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans", size: 15)!]
            
            let screen_width = UIScreen.main.bounds.size.width
            let details_view_width = screen_width - 60
            
            let estimated_description_frame = NSString(string: textView.text).boundingRect(with: CGSize(width: details_view_width, height: 1000), options: .usesLineFragmentOrigin, attributes: description_attributes, context: nil)
            
            self.description_height_constraint = self.description_text_view.heightAnchor.constraint(equalToConstant: estimated_description_frame.height + 20)
            self.description_height_constraint.isActive = true
            
            scroll_view.contentSize = CGSize(width: self.view.frame.width, height: create_button.frame.maxY + 100)
            
        default: break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= textView.character_limit;
    }

}

extension CreateEventController: GMSAutocompleteViewControllerDelegate {
    // Google Places Autocompletion
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        location_label.text = place.name
        // self.location_coordinate = place.coordinate
        self.place = place
        self.dismiss(animated: true, completion: nil) // dismiss after select place
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension CreateEventController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case tags_dropdown: return tags_array.count
        case ages_dropdown: return ages_array.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.tags_dropdown: return self.tags_array[row].rawValue
        case self.ages_dropdown: return self.ages_array[row].rawValue
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.tags_dropdown: self.tags_text_field.text = self.tags_array[row].rawValue
        case self.ages_dropdown: self.ages_text_field.text = self.ages_array[row].rawValue
        default: break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.tags_text_field: self.tags_text_field.text = self.tags_array[0].rawValue
        case self.ages_text_field: self.ages_text_field.text = self.ages_array[0].rawValue
        case self.starttime_text_field:
            if self.starttime_text_field.text == self.starttime_text_field.placeholder {
                self.start_time = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd h:mm a"
                self.starttime_text_field.text = "\(dateFormatter.string(from: Date()))"
            }
            
            if let date_picker = self.endtime_text_field.inputView as? UIDatePicker {
                date_picker.minimumDate = Date()
                var max = Calendar.current.date(byAdding: .hour, value: 17, to: Date())!
                max = Calendar.current.date(byAdding: .minute, value: 59, to: max)!
                date_picker.maximumDate = max
            }
            
        case self.endtime_text_field:
            if let starttime = self.start_time {
                self.addDatePickerToEndTime(withStartDate: starttime)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd h:mm a"
                self.endtime_text_field.text = "\(dateFormatter.string(from: (endtime_text_field.inputView as! UIDatePicker).minimumDate!))"
            }
            else {
                self.showAlert(title: "Error", message: "A start time must be entered before entering an end time", acceptence_text: "Okay", cancel: false, completion: nil)
            }
            
        default: break
        }
    }
    
}
