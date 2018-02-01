//
//  Popup.swift
//  Evo
//
//  Created by Admin on 6/24/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

class PopupCompletionView: UIView {
    func constrainContents() {
        fatalError("PopupCompletionView.constrainContents not overriden")
    }
}


@objc protocol SingleOptionPopupCompletionViewDelegate: class {
    @objc func handleCompletion()
}

class SingleOptionPopupCompletionView: PopupCompletionView {
    
    weak var delegate: SingleOptionPopupCompletionViewDelegate!
    
    lazy var completion_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .EVO_blue
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 24)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self.delegate, action: #selector(self.delegate.handleCompletion), for: .touchUpInside)
        return button
    }()
    
    override func constrainContents() {
        self.addSubview(self.completion_button)
        
        self.completion_button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.completion_button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.completion_button.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.completion_button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init(_ delegate: SingleOptionPopupCompletionViewDelegate, button_title: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.completion_button.setTitle(button_title, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@objc protocol DualOptionPopupCompletionViewDelegate: class {
    @objc func handleCompletion1()
    @objc func handleCompletion2()
}

class DualOptionPopupCompletionView: PopupCompletionView {
    
    weak var delegate: DualOptionPopupCompletionViewDelegate!
    
    lazy var completion_button1: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 24)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self.delegate, action: #selector(self.delegate.handleCompletion1), for: .touchUpInside)
        return button
    }()
    
    lazy var completion_button2: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .EVO_blue
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 24)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self.delegate, action: #selector(self.delegate.handleCompletion2), for: .touchUpInside)
        return button
    }()
    
    override func constrainContents() {
        self.addSubview(self.completion_button1)
        self.addSubview(self.completion_button2)
        
        self.completion_button1.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.completion_button1.rightAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.completion_button1.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.completion_button1.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        self.completion_button2.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.completion_button2.leftAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.completion_button2.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.completion_button2.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init(_ delegate: DualOptionPopupCompletionViewDelegate, button_title1: String, button_title2: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.completion_button1.setTitle(button_title1, for: .normal)
        self.completion_button2.setTitle(button_title2, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol PopupViewDelegate: class {
    func close()
    func changePopup(to popup: PopupView)
    // func showAlert(title: String?, message: String?, cancel: Bool, completion: ((UIAlertAction)->Void)?)
}

class PopupView: UIView {
    
    weak var delegate: PopupViewDelegate?
    
    required init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            self.removeFromSuperview()
        }
    }
    
    
    var completion_view: PopupCompletionView! {
        didSet {
            self.addSubview(self.completion_view)
            
            self.completion_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.completion_view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.completion_view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            self.completion_view.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            self.completion_view.constrainContents()
        }
    }
    
}
