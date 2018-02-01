//
//  Profile+handlers.swift
//  Evo
//
//  Created by Admin on 3/31/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

extension ProfileController {
    
    internal func observeProfile() {
        self.entity_ref.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            Profile.load(with: dictionary) { profile in
                guard let profile = profile else { return }
                
                self.datasource = ProfileDatasource(profile, self.profile_type)
                self.observeEvents()
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    internal func setUpSettingsGearButton() {
        let settings_button = UIButton(type: .system)
        settings_button.setImage(#imageLiteral(resourceName: "menu_settings_button_emblem").withRenderingMode(.alwaysOriginal), for: .normal)
        settings_button.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        settings_button.contentMode = .scaleAspectFit
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settings_button)
    }
}

extension ProfileController {
    
    // add header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: ProfileHeader.height)
    }
    
}

extension YourProfileHeader {
    
    @objc internal func openEditProfilePage() {
        if let controller = self.controller as? ProfileController, let event_datasourse = controller.datasource as? ProfileDatasource {
            controller.navigationController?.pushViewController(EditProfileController(with: event_datasourse.profile), animated: true)
        }
    }
    
}

extension OthersProfileHeader {
    
    @objc internal func handleFollow() {
        guard let current_uid = Auth.auth().currentUser?.uid else { return }
        
        /* if following then unfollow and change button to "follow"
         * if not following then follow and change button to "unfollow"
         */
        
        Profile.isFollowing(current_uid, self.profile.id) { (following) in
            self.button_mode = following ? .follow : .unfollow
            (following ? Profile.unfollow : Profile.follow)(current_uid, self.profile.id) // cool syntax init
        }
    }
    
}

extension ProfileFollowingView {
    
    @objc internal func openGroupsListPage() {
        self.openListPage(list_type: .groups)
    }
    
    @objc internal func openFollowersListPage() {
        self.openListPage(list_type: .followers)
    }
    
    @objc internal func openFollowingListPage() {
        self.openListPage(list_type: .followings)
    }
    
    private func openListPage(list_type: ProfileAndGroupListController.ListType) {
        guard let profile_header = self.superview as? ProfileHeader,
            let profile_controller = profile_header.controller else { return }
        
        profile_controller.navigationController?.pushViewController(ProfileAndGroupListController(profile_header.profile.id, list_type), animated: true)
    }
}

class BaseImagePickerController: UIImagePickerController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func fillInformation() {
        // public
        if let image_url = self.profile.image_url {
            self.profile_image_view.kf.setImage(with: URL(string: image_url))
        }
        else {
            self.profile_image_view.image = #imageLiteral(resourceName: "default_user_image")
        }
        
        self.profile_information_container_view.name_text_field.text = self.profile.name
        self.profile_information_container_view.location_text_display.text = self.profile.location
        self.profile_information_container_view.age_text_field.text = self.profile.age.map { String($0) }
        
        // private
        self.profile_information_container_view.email_text_field.text = self.profile.email
        self.profile_information_container_view.phone_text_field.text = self.profile.phone
        self.profile_information_container_view.gender_text_field.text = self.profile.gender
    }

    @objc internal func updateUserInfoToFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
            
        let ref = Database.database().reference().child(DBChildren.users).child(uid)
        
        self.setName(ref)
        self.setLocation(ref)
        self.setAge(ref)
        self.setEmail(ref)
        self.setPhone(ref)
        self.setGender(ref)
        self.setImage(ref)
        
        self.showAlert(
            title: "Success!",
            message: "Your information was updated successfully",
            acceptence_text: "Okay",
            cancel: false)
        { action in
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: {
            EvoOverlay.display()
        })
    }
    
    /// profile image selection
    
    @objc func selectProfileImage() {
        let picker = BaseImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: false, completion: {
            EvoOverlay.clear()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let edited_image = info["UIImagePickerControllerEditedImage"] as? UIImage
        let original_image = info["UIImagePickerControllerOriginalImage"] as? UIImage
        self.selected_image_fom_picker = edited_image ?? original_image
        
        dismiss(animated: false, completion: {
            EvoOverlay.display()
        })
    }
    
    func uploadImageToFirebase(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let image_url = self.profile.image_url {
            Storage.storage().reference(forURL: image_url).delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
        let image_name = NSUUID().uuidString
        let upload_data = image.jpeg(.medium)
        Storage.storage().reference().child("\(image_name).jpg").putData(upload_data!, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let url = metadata?.downloadURL() {
                self.sendPhotoChangeRequest(user: Auth.auth().currentUser!, url)
                
                Database.database().reference().child(DBChildren.users).child(uid).child(DBChildren.User.profile_image_url)
                    .setValue(url.absoluteString)
            }
            
        }
    }
    
    private func sendPhotoChangeRequest(user: User, _ url: URL) {
        let change_request = user.createProfileChangeRequest()
        change_request.photoURL = url
        change_request.commitChanges { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // helper functions
    
    private func setName(_ ref: DatabaseReference) {
        if let name = self.profile_information_container_view.name_text_field.text, !name.isEmpty {
            ref.child(DBChildren.User.name).setValue(name)
        }
    }
    
    private func setLocation(_ ref: DatabaseReference) {
        if let location = self.profile_information_container_view.location_text_display.text, !location.isEmpty {
            ref.child(DBChildren.User.location).setValue(location)
        }
    }
    
    private func setAge(_ ref: DatabaseReference) {
        if let age = self.profile_information_container_view.age_text_field.text {
            ref.child(DBChildren.User.age).setValue(UInt(age))
        }
    }
    
    private func setEmail(_ ref: DatabaseReference) {
        if let email = self.profile_information_container_view.email_text_field.text, !email.isEmpty {
            ref.child(DBChildren.User.email).setValue(email)
        }
    }
    
    private func setPhone(_ ref: DatabaseReference) {
        if let phone = self.profile_information_container_view.phone_text_field.text, !phone.isEmpty {
            ref.child(DBChildren.User.phone).setValue(phone)
        }
    }
    
    private func setGender(_ ref: DatabaseReference) {
        if let gender = self.profile_information_container_view.gender_text_field.text {
            ref.child(DBChildren.User.gender).setValue(gender)
        }
    }
    
    private func setImage(_ ref: DatabaseReference) {
        if let selected_image = self.selected_image_fom_picker {
            self.uploadImageToFirebase(selected_image)
        }
    }
    
}

extension EditProfileController: ProfileInformationContainerViewDelegate {
    
    internal func chooseLocation() {
        guard let coord = MapController.current_location?.coordinate else {
            self.profile_information_container_view.location_text_display.text = CreateEventController.location_error_message
            return
        }
        
        let autocomplete_controller = GMSAutocompleteViewController()
        autocomplete_controller.delegate = self
        autocomplete_controller.modalPresentationStyle = .overCurrentContext
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocomplete_controller.autocompleteFilter = filter
        
        let north_east = locationWithBearing(bearing: Double.pi / 4, distanceMeters: meters(fromMiles: 4), origin: coord)
        let south_west = locationWithBearing(bearing: 5 * Double.pi / 4, distanceMeters: meters(fromMiles: 4), origin: coord)
        
        autocomplete_controller.autocompleteBounds = GMSCoordinateBounds(coordinate: north_east, coordinate: south_west)
        
        self.present(autocomplete_controller, animated: true, completion: nil)
    }
    
}

extension EditProfileController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case age_dropdown: return ages_array.count
        case gender_dropdown: return 2
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case age_dropdown: return ages_array[row]
        case gender_dropdown: return genders_array[row]
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case age_dropdown: self.profile_information_container_view.age_text_field.text = self.ages_array[row]
        case gender_dropdown: self.profile_information_container_view.gender_text_field.text = self.genders_array[row]
        default: break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.profile_information_container_view.age_text_field: self.age_dropdown.isHidden = false
        case self.profile_information_container_view.gender_text_field: self.gender_dropdown.isHidden = false
        default: break
        }
    }
    
}

func getLocationName(fromCoord coord: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let placemark = placemarks?[0], let city = placemark.locality, let state = placemark.administrativeArea, let country = placemark.isoCountryCode {
            completion(city + ", " + state + ", " + country)
        }
        else {
            completion(nil)
        }
    }
}

extension EditProfileController: GMSAutocompleteViewControllerDelegate {
    // Google Places Autocompletion
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        getLocationName(fromCoord: place.coordinate) { name in
            self.profile_information_container_view.location_text_display.text = name
            self.dismiss(animated: true, completion: nil) // dismiss after select place
        }
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
