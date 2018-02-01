//
//  EventCellBackgroundGenerator.swift
//  Evo
//
//  Created by Admin on 7/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import UIKit

/* class which randomly chooses the background of an event feed cell given an event type */
class EventCellBackgroundGenerator {
    
    private static var random_number: UInt32 {
        return arc4random_uniform(7) + UInt32(1)
    }
    
    // returns the filename of a randomly selected image given an event type
    static func getImageName(ofType title: String) -> String {
        return title == "Food/Drink" ? "FoodDrink_\(random_number)" : "\(title)_\(random_number)"
    }
    
}
