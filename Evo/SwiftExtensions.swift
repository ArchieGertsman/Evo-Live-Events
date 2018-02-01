//
//  Extensions.swift
//  Evo
//
//  Created by Admin on 6/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/// all extensions of external classes used in project

extension UINavigationBar {
    
    static func initNavBar() {
        let appearence = UINavigationBar.appearance()
        appearence.barTintColor = .EVO_blue
        let titleDict = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 24)!]
        appearence.titleTextAttributes = titleDict
        appearence.isTranslucent = false
        appearence.tintColor = .white
    }
}

extension UIColor {
    
    // custom colors used throughout the app
    static let EVO_text_dark_gray = UIColor(r: 80, g: 80, b: 80)
    static let EVO_text_gray = UIColor(r: 100, g: 100, b: 100)
    static let EVO_text_light_gray = UIColor(r: 180, g: 180, b: 180)
    static let EVO_border_gray = UIColor(r: 180, g: 180, b: 180)
    static let EVO_background_gray = UIColor(r: 240, g: 240, b: 240)
    static let EVO_blue = UIColor(r: 0, g: 85, b: 164)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a / 255)
    }
    
}

extension UIViewController {
    
    // custom setup for navigation bar and controller. Call in viewDidLoad
    func initEvoStyle(title: String) {
        UINavigationBar.initNavBar()
        self.view.backgroundColor = .EVO_background_gray
        
        self.title = title
        let tlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        tlabel.text = self.title
        tlabel.textColor = .white
        tlabel.font = UIFont(name: "GothamRounded-Medium", size: 24.0)
        tlabel.backgroundColor = .clear
        tlabel.adjustsFontSizeToFitWidth = true
        tlabel.textAlignment = .center
        self.navigationItem.titleView = tlabel
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.hideKeyboardWhenTappedAround()
    }
    
    internal func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc internal func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String?, message: String?, acceptence_text: String, cancel: Bool, completion: ((UIAlertAction)->Void)?) {
        // pop-up that describes the event creation error
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptence_text, style: .default, handler: completion))
        if cancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: { self.view.alpha = 0.0 }) { value in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    enum DismissalMode {
        case normal
        case fade
    }
    
    @objc internal func dismissWithoutCompletionNormally() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func dismissWithoutCompletionFade() {
        self.dismiss(completion: nil)
    }
    
    @objc internal func popWithoutCompletion() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

private var vc_key: UInt8 = 0

extension UIViewController {
    
    @objc var viewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &vc_key) as? UIViewController
        }
        set(newValue) {
            objc_setAssociatedObject(self, &vc_key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static func getNavigationController() -> UINavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    }
    
    static func getTopViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
}

private var placeholder_associationKey: UInt8 = 0
private var character_limit_associationKey: UInt8 = 1

extension UITextView {
    var placeholder: String! {
        get {
            return objc_getAssociatedObject(self, &placeholder_associationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &placeholder_associationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var character_limit: Int! {
        get {
            return objc_getAssociatedObject(self, &character_limit_associationKey) as? Int
        }
        set(newValue) {
            objc_setAssociatedObject(self, &character_limit_associationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIFont {
    convenience init(size: CGFloat) {
        self.init(name: "GothamRounded-Light", size: size)!
    }
}

extension Array {
    
    // find out where to insert something
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
    
}

extension UIImage {
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
}

extension UITableViewCell {
    
    var indexPath: IndexPath? {
        return (superview as? UITableView)?.indexPath(for: self)
    }
    
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    func replace(_ index: Int, _ newChar: Character) -> String {
        var chars = Array(self.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
    
}

extension Character {
    
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
    
    var isAlpha: Bool {
        return (self >= "A" && self <= "Z") || (self >= "a" && self <= "z")
    }
    
    var toLower: Character {
        return self.isAlpha ? (self >= "a" && self <= "z") ? self : Character(UnicodeScalar(self.asciiValue! + 32)!) : self
    }
    
    var toUpper: Character {
        return self.isAlpha ? (self >= "A" && self <= "Z") ? self : Character(UnicodeScalar(self.asciiValue! - 32)!) : self
    }
    
}

extension CLLocationCoordinate2D {
    
    static func==(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) -> Bool {
        return c1.latitude == c2.latitude && c1.longitude == c2.longitude
    }
    
}
