//
//  AddGroupMembersView.swift
//  Evo
//
//  Created by Admin on 6/24/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import CLTokenInputView
import Firebase

class AddGroupMembersPopup: PopupView {
    
    typealias NamesDict = Dictionary<String, String>
    
    var token_view: TokenView!
    
    let gid: String
    var names_dict = NamesDict()
    var names: Array<String> {
        get {
            return Array(names_dict.keys)
        }
    }
    
    required init(_ names_dict: NamesDict, _ gid: String) {
        self.gid = gid
        self.names_dict = names_dict
        
        super.init() // inits frame of entire view
        self.frame = self.getPopupViewSize()
        
        self.token_view = TokenView(self.names, field_name: "Add")
        self.token_view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(token_view)
        
        token_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        token_view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        token_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        self.completion_view = SingleOptionPopupCompletionView(self, button_title: "Add")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func getPopupViewSize() -> CGRect {
        
        let screen_width = UIScreen.main.bounds.size.width
        let screen_height = UIScreen.main.bounds.size.height
        
        let width = screen_width * 0.8
        let height: CGFloat = 250
        let x = (screen_width / 2) - (width / 2)
        let y = (screen_height / 2) - (height / 2)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension AddGroupMembersPopup: SingleOptionPopupCompletionViewDelegate {
    
    func handleCompletion() {
        guard let delegate = self.delegate else {
            print("add members popup doesn't have delegated controller")
            return
        }
        
        let tokens = self.token_view.getAllTokens()
        
        guard tokens.count > 0 else {
            delegate.close()
            return
        }
        
        // users added by current user
        let uids = tokens.map { self.names_dict[$0.displayText] } as! [String]
        
        // add members to group
        Group.addMembers(uids, self.gid)
        
        delegate.close()
    }
    
}
