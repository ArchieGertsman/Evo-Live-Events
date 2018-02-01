//
//  Cells.swift
//  Evo
//
//  Created by Admin on 4/14/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import LBTAComponents
import CoreLocation

class EventFeedCell: DatasourceCell {
    
    static let height: CGFloat = 155
    var event: Event!
    
    override var datasourceItem: Any? {
        didSet {
            guard let event = datasourceItem as? Event else { return }
            self.load(with: event)
        }
    }
    
    /* views */
    
    /// hour marker view
    
    var hour_marker_view: EventFeedTimeMarkerView?
    
    /// standard views
    
    let background_image_view = UIImageView()
    
    let title_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 27)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let distance_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(size: 20)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let state_label: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.font = UIFont(name: "GothamRounded-Medium", size: 20)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let going_count_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var going_count: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 20)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewEventAttendees(gesture_recognizer:))))
        return label
    }()
    
    lazy var details_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("Details", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = UIFont(size: 20)
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showDetailsHandler), for: .touchUpInside)
        return button
    }()
    
    override func prepareForReuse() {
        self.going_count.text = nil
    }
}
