//
//  EvoFooter.swift
//  Evo
//
//  Created by Admin on 9/30/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import LBTAComponents

class EvoFooter: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            if let message = datasourceItem as? String {
                self.addMessageLabel(withText: message)
            }
            else {
                self.removeMessageLabel()
            }
        }
    }
    
    internal func addMessageLabel(withText text: String) {
        self.message_label = self.message_label_object
        self.message_label!.text = text
        self.addSubview(self.message_label!)
        
        self.message_label!.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.message_label!.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.message_label!.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        self.message_label!.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
    }
    
    internal func removeMessageLabel() {
        if let message_label = self.message_label {
            message_label.removeFromSuperview()
            message_label.removeConstraints(message_label.constraints)
            self.message_label = nil
        }
    }
    
    internal var message_label: UILabel?
    
    private var message_label_object: UILabel? {
        let label = UILabel()
        label.font = UIFont(size: 16)
        label.textColor = .EVO_text_gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}
