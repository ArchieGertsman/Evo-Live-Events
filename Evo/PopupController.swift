//
//  PopupController.swift
//  Evo
//
//  Created by Admin on 7/25/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

/* view controller which contains a PopupView */
class PopupController: UIViewController {

    var popup: PopupView!
    
    // c-tor which initializes the PopupView
    required init(with popup: PopupView) {
        self.popup = popup
        super.init(nibName: nil, bundle: nil)
        self.popup.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // sets up visuals of popup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let transparent_color = UIColor(r: 0, g: 0, b: 0, a: 190)
        self.view.backgroundColor = transparent_color
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleClose(gesture_recognizer:)))
        tgr.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tgr)
        
        self.view.addSubview(popup)
    }
    
    // if user taps somewhere outside of the popup then close the popup
    @objc func handleClose(gesture_recognizer: UIGestureRecognizer) {
        let location = gesture_recognizer.location(in: self.view)
        
        if gesture_recognizer.state == .ended && !self.popup.frame.contains(location) {
            self.close()
        }
    }
    
}

// extension which implements PopupViewDelegate methods
extension PopupController: PopupViewDelegate {
    
    // popup closing animation
    func close() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.alpha = 0.0
        }, completion: { value in
            // remove this view
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // change PopupViews
    func changePopup(to popup: PopupView) {
        self.popup.removeFromSuperview()
        self.popup = popup
        self.popup.delegate = self
        self.view.addSubview(self.popup)
    }
    
}
