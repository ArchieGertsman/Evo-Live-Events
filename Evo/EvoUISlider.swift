//
//  EvoUISlider.swift
//  Evo
//
//  Created by Admin on 9/7/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

/* to be implemented into any class which uses a CustomUISlider */
protocol CustomUISliderDelegate: class {
    func didChange(value: UInt)
}

/* UISlider wrapper class which has a custom EVO style and contains a label which displays the current slider value */
class CustomUISlider: UISlider {
    
    weak var delegate: CustomUISliderDelegate?
    
    private let step_value: Float = 2.0
    
    // stored property for the value in the label. Called distance because this slider is supposed to
    // be used for selecting an event radius/distance. `value` is already used to store the value of the slider
    var distance: UInt {
        get {
            return UInt(self.value)
        }
        set(new_val) {
            self.value = Float(new_val)
            self.distance_label.text = String(new_val)
        }
    }
    var label_color: UIColor {
        get {
            return self.distance_label.textColor
        }
        set(new_color) {
            self.distance_label.textColor = new_color
        }
    }
    
    // label which displays the number stored by `distance`
    private lazy var distance_label: UILabel = {
        let label = UILabel()
        label.text = "\(Int(self.value))"
        label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // used to determine whether to place the current slider value label above or below the slider
    enum LabelPosition {
        case above
        case under
    }
    
    init() {
        super.init(frame: .zero)
        
        // set up visuals
        self.minimumValue = 1
        self.maximumValue = 50
        self.value = 10.0
        self.isContinuous = true
        self.tintColor = .EVO_blue
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(self, action: #selector(self.valueChanged(sender:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // keeps original origin and width, changes height
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 7.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    // called outside of this class to add the label. Label isn't there by defult
    func addDistanceLabel(position: LabelPosition, _ handle_view: UIImageView) {
        self.addSubview(self.distance_label)
        
        self.distance_label.centerXAnchor.constraint(equalTo: handle_view.centerXAnchor, constant: -2).isActive = true
        switch position {
        case .above: self.distance_label.bottomAnchor.constraint(equalTo: handle_view.topAnchor, constant: -5).isActive = true
        case .under: self.distance_label.topAnchor.constraint(equalTo: handle_view.bottomAnchor, constant: 5).isActive = true
        }
    }
    
    // called when slider is slid
    @objc func valueChanged(sender: UISlider) {
        let new_step = roundf(self.value / self.step_value)
        self.setValue(new_step * self.step_value, animated: false)
        self.distance_label.text = "\(Int(self.value))"
        self.delegate?.didChange(value: UInt(self.value))
    }
    
}
