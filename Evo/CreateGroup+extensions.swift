//
//  CreateGroup+extensions.swift
//  Evo
//
//  Created by Admin on 6/17/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import KSTokenView

extension CreateGroupController {
    
    @objc func createGroup() {
        guard let name = name_text_view.text, name != name_text_view.placeholder,
            let description = description_text_view.text, description != description_text_view.placeholder
            else {
                showGroupCreationFailureAlert(message: "All fields must be filled")
                return
        }
        
        _ = self.navigationController?.popToRootViewController(animated: true)
        
        let group = self.getGroupDict(name, description)
        self.addGroupToFirebase(group) {
            
            Analytics.logEvent("create_group", parameters: nil)
            Analytics.logEvent("group_privacy", parameters: ["is_private" : self.privacy_switch.isOn])
            
            DispatchQueue.main.async {
                Group.initGroup(with: group[DBChildren.Group.id]! as! String) { group in
                    if let group = group {
                        UIApplication.topViewController()?.viewController?.navigationController?.pushViewController(GroupController(of: group), animated: true)
                    }
                }
            }
        }
    }
    
    func getGroupID() -> String {
        return Database.database().reference().child(DBChildren.groups).childByAutoId().key
    }
    
    func getGroupDict(_ name: String, _ description: String) -> [String : Any] {
        let group = [
            DBChildren.Group.id: self.getGroupID(),
            DBChildren.Group.owner_uid: Auth.auth().currentUser!.uid,
            DBChildren.Group.name: name,
            DBChildren.Group.description: description,
            DBChildren.Group.privacy: self.privacy_switch.isOn
            // DBChildren.Group.members: 0
        ] as [String : Any]
        
        return group
    }
    
    func addGroupToFirebase(_ group: [String : Any], completion: @escaping () -> Void) {
        
        let gid = group[DBChildren.Group.id]! as! String
        Database.database().reference().child(DBChildren.groups).child(gid).setValue(group)
        
        let tokens = self.add_members_token_view.getAllTokens()
        
        // users added by current user
        var uids = tokens.map { self.names_dict[$0.displayText] } as! [String]
        
        // add current user to list of members to add to group
        uids.append(Auth.auth().currentUser!.uid)
        
        // add members to group
        Group.addMembers(uids, gid)
        
        if let image = self.group_image {
            self.uploadImageToFirebase(image, completion: { (url) in
                Database.database().reference().child(DBChildren.groups).child(gid).child(DBChildren.Group.image_url).setValue(url)
                completion()
            })
        }
        else {
            completion()
        }
    }

    
    func showGroupCreationFailureAlert(message: String) {
        // pop-up that describes the event creation error
        let alert = UIAlertController(title: "Failed to create group", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension CreateGroupController: UITextViewDelegate {
    /* text view mods */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .EVO_text_light_gray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textView.placeholder
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == self.description_text_view else { return }
        
        self.description_height_constraint.isActive = false
        
        let description_attributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans", size: 15)!]
        
        let screen_width = UIScreen.main.bounds.size.width
        let details_view_width = screen_width - 60
        
        let estimated_description_frame = NSString(string: textView.text).boundingRect(with: CGSize(width: details_view_width, height: 1000), options: .usesLineFragmentOrigin, attributes: description_attributes, context: nil)
        
        self.description_height_constraint = self.description_text_view.heightAnchor.constraint(equalToConstant: estimated_description_frame.height + 20)
        self.description_height_constraint.isActive = true
        
        scroll_view.contentSize = CGSize(width: self.view.frame.width, height: create_button.frame.maxY + 100)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars <= textView.character_limit;
    }
    
}

extension CreateGroupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// profile image selection
    
    @objc func selectGroupImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: false, completion: {
            EvoOverlay.clear()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selected_image_fom_picker: UIImage?
        
        if let edited_image = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selected_image_fom_picker = edited_image
        }
        else if let original_image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selected_image_fom_picker = original_image
        }
        
        if let selected_image = selected_image_fom_picker {
            image_view.image = selected_image
            self.group_image = selected_image
        }
        
        dismiss(animated: false, completion: {
            EvoOverlay.display()
        })
    }
    
    func uploadImageToFirebase(_ image: UIImage, completion: @escaping (_ url: String) -> Void) {
        let image_name = NSUUID().uuidString
        let upload_data = image.jpeg(.medium)
        Storage.storage().reference().child("\(image_name).jpg").putData(upload_data!, metadata: nil) { metadata, error in
            if let error = error {
                print(error)
                return
            }
            
            completion((metadata?.downloadURL()?.absoluteString)!)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: {
            EvoOverlay.display()
        })
    }
    
}












