//
//  EventInvitationPopup.swift
//  Evo
//
//  Created by Admin on 8/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol EventInvitationPopupDelegate: PopupViewDelegate {
    func viewEntityPage()
}

class EventInvitationPopup: PopupView {
    
    typealias NamesDict = Dictionary<String, String>
    
    internal let event: Event
    let names_dict: NamesDict
    var names: Array<String> {
        return Array(names_dict.keys)
    }
    
    var token_view: TokenView!
    
    private func showMessageForCreator() {
        switch self.event.accessibility {
        case .public_: self.instructions_text_view.text = "\(event.title) is a public event. You can invite anyone you are following! Goers of this event will also be able to invite anyone on their following list."
        case .my_crowds: self.instructions_text_view.text = "\(event.title) is a My-Crowds-Only event. You can invite anyone you are following! Goers of this event will be able to invite anyone on their following list who also has this event available on their My Crowds page."
        case .invite_only: self.instructions_text_view.text = "\(event.title) is an invite only event. Only you, the creator, can invite anyone you are following."
        case .private_group: self.instructions_text_view.text = "\(event.title) is a private group event. You can only invite other group members."
        }
    }
    
    private func showStandardMessage() {
        switch self.event.accessibility {
        case .public_: self.instructions_text_view.text = "\(event.title) is a public event. You can invite anyone you are following!"
        case .my_crowds: self.instructions_text_view.text = "\(event.title) is a My-Crowds-Only event. You can invite anyone you are following who also has this event available on their My Crowds page."
        case .invite_only: self.instructions_text_view.text = "\(event.title) is an invite only event. Only you, the creator, can invite anyone you are following."
        case .private_group: self.instructions_text_view.text = "\(event.title) is a private group event. You can only invite other group members."
        }
    }
    
    required init(_ names_dict: NamesDict, _ event: Event) {
        self.event = event
        self.names_dict = names_dict
        
        super.init() // inits frame of entire view
        self.frame = self.getPopupViewSize()
        
        event.uid != Auth.auth().currentUser!.uid ? self.showStandardMessage() : self.showMessageForCreator()
        
        self.token_view = TokenView(self.names, field_name: "Invite")
        self.token_view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.instructions_text_view)
        self.addSubview(self.token_view)

        self.instructions_text_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.instructions_text_view.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        self.instructions_text_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        let text_view_attributes = [NSAttributedStringKey.font: UIFont(size: 14)]
        
        let estimated_text_view_frame = NSString(string: self.instructions_text_view.text).boundingRect(with: CGSize(width: self.frame.size.width - 120, height: 1000), options: .usesLineFragmentOrigin, attributes: text_view_attributes, context: nil)
        
        self.instructions_text_view.heightAnchor.constraint(equalToConstant: estimated_text_view_frame.height).isActive = true
        
        self.token_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.token_view.topAnchor.constraint(equalTo: self.instructions_text_view.bottomAnchor, constant: -20).isActive = true
        self.token_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        self.completion_view = SingleOptionPopupCompletionView(self, button_title: "Invite")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private let instructions_text_view: UITextView = {
        let text_view = UITextView()
        text_view.font = UIFont(size: 14)
        text_view.isScrollEnabled = false
        text_view.textColor = .EVO_text_gray
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    func getPopupViewSize() -> CGRect {
        
        let screen_width = UIScreen.main.bounds.size.width
        let screen_height = UIScreen.main.bounds.size.height
        
        let width = screen_width * 0.8
        let height: CGFloat = 400
        let x = (screen_width / 2) - (width / 2)
        let y = (screen_height / 2) - (height / 2)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

extension EventInvitationPopup: SingleOptionPopupCompletionViewDelegate {
    
    func handleCompletion() {
        guard let delegate = self.delegate else { print("add members popup doesn't have delegated controller"); return }
        
        let tokens = self.token_view.getAllTokens()
        
        guard tokens.count > 0 else {
            delegate.close()
            return
        }
        
        // users invited by current user
        let uids = tokens.map { self.names_dict[$0.displayText] } as! [String]
        
        // invite to event
        for uid in uids {
            Event.invite(uid, self.event.id)
        }
        
        delegate.close()
    }
    
}
