//
//  HourMarkerView.swift
//  Evo
//
//  Created by Admin on 5/29/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

class EventFeedTimeMarkerView: UIView {
    
    static let height: CGFloat = 30
    
    /// must call this constructor in order to enable design
    required init(with date: Date, by mode: Time.Mode) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: EventFeedTimeMarkerView.height))
        self.addSubviews(with: date, by: mode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews(with date: Date, by mode: Time.Mode) {
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch mode {
        case .hour:
            formatter.dateFormat = "hh:00 a"
            
            if calendar.isDateInYesterday(date) {
                 time_label.text = "Yesterday"
            }
            else if calendar.isDateInToday(date) {
                time_label.text = formatter.string(from: date)
            }
            else {
                time_label.text = "Tomorrow"
            }
            
        case .date:
            formatter.dateFormat = "MM/dd/yy"
            
            if calendar.isDateInToday(date) {
                time_label.text = "Today"
            } else if calendar.isDateInTomorrow(date) {
                time_label.text = "Tomorrow"
            } else {
                time_label.text = formatter.string(from: date)
            }
        }
        
        self.addSubview(line_view)
        self.addSubview(time_label)
        
        line_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line_view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        line_view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line_view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        time_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        time_label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        time_label.widthAnchor.constraint(equalToConstant: time_label.intrinsicContentSize.width + 10).isActive = true
    }
    
    /// views
    
    let time_label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "GothamRounded-Medium", size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let line_view: UIView = {
        let view = UIView()
        view.backgroundColor = .EVO_text_gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
}
