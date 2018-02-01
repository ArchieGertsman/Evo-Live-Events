//
//  AddGroupMembersController.swift
//  Evo
//
//  Created by Admin on 7/24/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase

/* popup thatpops up when the add members button is tapped on a group's page. Uses a TokenView */
class AddGroupMembersController: PopupController {
    
    typealias NamesDict = Dictionary<String, String> // makes a uid to a name
    
    weak var delegate: GroupController?
    let gid: String
    var names_dict = NamesDict()
    var names: [String] {
        return Array(names_dict.keys)
    }
    
    required init(_ names_dict: NamesDict, _ gid: String) {
        self.names_dict = names_dict
        self.gid = gid
        super.init(with: AddGroupMembersPopup(names_dict, gid))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(with popup: PopupView) {
        fatalError("init(with:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if user clicks outside of popup, then close popup
        let transparent_color = UIColor(r: 0, g: 0, b: 0, a: 190)
        self.view.backgroundColor = transparent_color
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleClose(gesture_recognizer:)))
        tgr.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tgr)
    }

}
