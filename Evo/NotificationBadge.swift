//
//  NotificationBadge.swift
//  Evo
//
//  Created by Admin on 9/7/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

/* UILabel wrapper class which creates a circular label that looks like an iOS notification badge */
class NotificationBadge: UILabel {
    
    // number displayed by badge
    private var num: UInt! {
        get {
            return self.num
        }
        set(new_num) {
            self.num = new_num
            self.text = String(num)
        }
    }
    
    var diameter: CGFloat = 25.0
    private static let color = UIColor(r: 250, g: 4, b: 0)
    
    // constructor which takes in the display number and sets up visuals
    required init(num: UInt) {
        super.init(frame: .zero)
        
        self.backgroundColor = NotificationBadge.color
        self.textColor = .white
        self.text = String(num)
        self.font = UIFont(name: "GothamRounded-Medium", size: 15)
        self.textAlignment = .center
        self.layer.cornerRadius = self.diameter / 2.0
        self.adjustsFontSizeToFitWidth = true
        self.layer.masksToBounds = true
    }
    
    // optional constructor that takes in the display number and a custom diameter
    convenience init(num: UInt, diameter: CGFloat) {
        self.init(num: num)
        self.diameter = diameter
        self.layer.cornerRadius = self.diameter / 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
