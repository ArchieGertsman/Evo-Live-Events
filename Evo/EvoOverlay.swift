//
//  EvoOverlay.swift
//  Evo
//
//  Created by Admin on 3/24/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import UIKit

class EvoOverlay {
    
    class func display() {
        addToWindow()
        constrain()
    }
    
    class func clear() {
        evo_button.removeFromSuperview()
        // status_bar_color_view.removeFromSuperview()
        copyright_bar.removeFromSuperview()
        message1_label.removeFromSuperview()
        message2_label.removeFromSuperview()
    }
    
    private class func addToWindow() {
        UIApplication.shared.keyWindow!.addSubview(status_bar_color_view)
        UIApplication.shared.keyWindow!.addSubview(copyright_bar)
        UIApplication.shared.keyWindow!.addSubview(message1_label)
        UIApplication.shared.keyWindow!.addSubview(message2_label)
        UIApplication.shared.keyWindow!.addSubview(evo_button)
    }
    
    private class func constrain() {
        status_bar_color_view.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor).isActive = true
        status_bar_color_view.topAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.topAnchor).isActive = true
        status_bar_color_view.widthAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.widthAnchor).isActive = true
        status_bar_color_view.heightAnchor.constraint(equalToConstant: statusBarHeight()).isActive = true
        
        copyright_bar.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor).isActive = true
        copyright_bar.bottomAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.bottomAnchor).isActive = true
        copyright_bar.widthAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.widthAnchor).isActive = true
        copyright_bar.heightAnchor.constraint(equalToConstant: EvoOverlay.height_of_copyright_bar).isActive = true
        
        let message1_length = message1_label.intrinsicContentSize.width
        
        message1_label.leftAnchor.constraint(equalTo: copyright_bar.leftAnchor, constant: 5).isActive = true
        message1_label.topAnchor.constraint(equalTo: copyright_bar.topAnchor).isActive = true
        message1_label.widthAnchor.constraint(equalToConstant: message1_length).isActive = true
        message1_label.heightAnchor.constraint(equalTo: copyright_bar.heightAnchor).isActive = true
        
        let message2_length = message2_label.intrinsicContentSize.width
        
        message2_label.rightAnchor.constraint(equalTo: copyright_bar.rightAnchor, constant: -5).isActive = true
        message2_label.topAnchor.constraint(equalTo: copyright_bar.topAnchor).isActive = true
        message2_label.widthAnchor.constraint(equalToConstant: message2_length).isActive = true
        message2_label.heightAnchor.constraint(equalTo: copyright_bar.heightAnchor).isActive = true
        
        evo_button.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor).isActive = true
        evo_button.bottomAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.bottomAnchor, constant: -8).isActive = true
        evo_button.widthAnchor.constraint(equalToConstant: 65).isActive = true
        evo_button.heightAnchor.constraint(equalToConstant: 65).isActive = true
    }
    
    class func constrainButton(to view: UIView) {
        evo_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        evo_button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        evo_button.widthAnchor.constraint(equalToConstant: 65).isActive = true
        evo_button.heightAnchor.constraint(equalToConstant: 65).isActive = true
    }
    
    class func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
    static let status_bar_color_view: UIView = {
        let view = UIView()
        view.backgroundColor = .EVO_blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    static let height_of_copyright_bar: CGFloat = 15.0
    
    static let copyright_bar: UIView = {
        let view = UIImageView()
        view.backgroundColor = .EVO_blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    static let message1_label: UILabel = {
        let label = UILabel()
        label.text = "All Rights Reserved"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let message2_label: UILabel = {
        let label = UILabel()
        label.text = "©Evo Events LLC"
        label.textColor = .white
        label.font = UIFont(name: "OpenSans", size: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let evo_button = EvoOverlay.createEvoButton()
    
    class func createEvoButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 7
        button.backgroundColor = .EVO_blue
        button.setImage(UIImage(named: "evo_overlay_logo"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(EvoOverlay.handleButtonClick), for: .touchUpInside)
        return button
    }
    
}
