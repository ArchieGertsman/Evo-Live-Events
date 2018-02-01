//
//  EntitySearchController.swift
//  Evo
//
//  Created by Admin on 8/13/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EntitySearchController: UITableViewController {
    
    lazy var search_bar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 275, height: 20))
    var entities = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(EntitySearchCell.self, forCellReuseIdentifier: "EntityCell")
        
        let gesture_recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(recognizer:)))
        tableView.addGestureRecognizer(gesture_recognizer)
        
        self.setUpNavigationItems()
    }
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer)  {
        let location = recognizer.location(in: self.tableView)
        let path = self.tableView.indexPathForRow(at: location)
        if let indexPathForRow = path {
            self.tableView(self.tableView, didSelectRowAt: indexPathForRow)
        } else {
            self.search_bar.endEditing(true)
        }
    }
    
    func setUpSearchBar() {
        self.search_bar.delegate = self
        self.search_bar.placeholder = "Search for people and groups"
        self.search_bar.barTintColor = UIColor(r: 1, g: 64, b: 147)
        self.search_bar.autocapitalizationType = .none
        self.search_bar.autocorrectionType = .no
        
        for view in search_bar.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UITextField.self) {
                    (subview as! UITextField).backgroundColor = UIColor(r: 1, g: 64, b: 147)
                }
            }
        }
    }
    
    func setUpNavigationItems() {
        self.setUpSearchBar()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: search_bar)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.popWithoutCompletion))
    }
    
    internal func getLetterCasePermutations(of words: [String]) -> [String] {
        var ret = [String]()
        
        var i = 0, n = Int(pow(2, Double(words.count)))
        
        while i < n {
            var permutation_arr = words
            for j in 0 ..< words.count {
                permutation_arr[j] = permutation_arr[j].replace(0, (isBitSet(n: i, offset: j)) ? words[j][0].toUpper : words[j][0])
            }
            
            let permutation = permutation_arr.joined(separator: " ")
            
            if !ret.contains(permutation) {
                ret.append(permutation)
            }
            
            i += 1
        }
        
        return ret
    }
    
    internal func isBitSet(n: Int, offset: Int) -> Bool {
        return (n >> offset & 1) != 0;
    }
    
    internal enum SearchMode: String {
        case user = "users"
        case group = "groups"
    }
    
    internal func search(for str: String, search_mode: SearchMode, completion: @escaping ([Any]) -> Void) {
        
        let entity_path: String
        let name_path: String
        
        switch search_mode {
        case .user:
            entity_path = DBChildren.users
            name_path = DBChildren.User.name
            
        case .group:
            entity_path = DBChildren.groups
            name_path = DBChildren.Group.name
        }
        
        Database.database().reference().child(entity_path)
            .queryOrdered(byChild: name_path)
            .queryStarting(atValue: str)
            .queryEnding(atValue: str + "\u{F8FF}")
            .observeSingleEvent(of: .value, with: { snapshot in
                
                guard let entities_dict = snapshot.value as? [String: AnyObject] else {
                    completion([Any]())
                    return
                }
                
                switch search_mode {
                case .user:
                    Profile.initProfiles(with: Array(entities_dict.keys)) { profiles in
                        completion(profiles)
                    }
                    
                case .group:
                    Group.initGroups(with: Array(entities_dict.keys)) { groups in
                        completion(groups)
                    }
                }
                
            })
    }

}

extension EntitySearchController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity_cell = tableView.dequeueReusableCell(withIdentifier: EntitySearchCell.reuse_identifier, for: indexPath) as! EntitySearchCell
        entity_cell.entity = self.entities[indexPath.row]
        return entity_cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = (tableView.cellForRow(at: indexPath) as! EntitySearchCell).entity
        
        if let profile = entity as? Profile {
            self.navigationController?.pushViewController(ProfileController(of: profile), animated: true)
        }
        else if let group = entity as? Group {
            self.navigationController?.pushViewController(GroupController(of: group), animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}

extension EntitySearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // clear searach results
        self.entities = [Any]()
        
        // if search is empty then clear table view
        guard !searchText.isEmpty else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        /* get all letter case permutations of words (from first letters) from search. I.e.:
         * String: "hello world"
         * Output: ["hello world", "Hello world", "Hello World", "hello World"]
         * for n words there are 2^n permutations
         */
        let permutations = getLetterCasePermutations(of: searchText.lowercased().components(separatedBy: " ").filter { !$0.isEmpty })
        let dispatch_group = DispatchGroup()
        
        for permutation in permutations {
            
            // search for profiles
            dispatch_group.enter()
            self.search(for: permutation, search_mode: .user) { entities in
                for e in entities {
                    
                    let contains = self.entities.contains {
                        if let profile = $0 as? Profile, let e = e as? Profile {
                            return profile.name == e.name
                        }
                        return false
                    }
                    
                    if !contains {
                        self.entities.append(e)
                    }
                }
                
                dispatch_group.leave()
            }
            
            // search for groups
            dispatch_group.enter()
            self.search(for: permutation, search_mode: .group) { entities in
                for e in entities {
                    
                    let contains = self.entities.contains {
                        if let group = $0 as? Group, let e = e as? Group {
                            return group.name == e.name
                        }
                        return false
                    }
                    
                    if !contains {
                        self.entities.append(e)
                    }
                }
                
                dispatch_group.leave()
            }
            
        }
        
        dispatch_group.notify(queue: .main) {
            
            // sort entire collection of entities alphabetically
            self.entities.sort {
                var name1: String?
                var name2: String?
                
                if let profile = $0 as? Profile {
                    name1 = profile.name
                }
                else if let group = $0 as? Group {
                    name1 = group.name
                }
                
                if let profile = $1 as? Profile {
                    name2 = profile.name
                }
                else if let group = $1 as? Group {
                    name2 = group.name
                }
                
                if let name1 = name1, let name2 = name2 {
                    return name1.lowercased() < name2.lowercased()
                }
                else {
                    return true
                }
            }
            self.tableView.reloadData()
        }
    }
    
}

fileprivate class EntitySearchCell: UITableViewCell {
    
    static let reuse_identifier = "EntityCell"
    private static let image_size: CGFloat = 45
    
    private lazy var image_view: UIImageView = {
        let y = (self.frame.size.height / 2) - (EntitySearchCell.image_size / 2)
        let image_view = UIImageView(frame: CGRect(x: 15, y: y, width: EntitySearchCell.image_size, height: EntitySearchCell.image_size))
        
        image_view.layer.cornerRadius = EntitySearchCell.image_size / 2
        image_view.layer.masksToBounds = true
        
        return image_view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: self.contentView.bounds.insetBy(dx: EntitySearchCell.image_size + 25, dy: 0))
        label.textColor = .black
        label.font = UIFont(name: "OpenSans-Regular", size: 18)
        return label
    }()
    
    var entity: Any? {
        didSet {
            self.clear()
            
            if let profile = self.entity as? Profile {
                self.addInfo(name: profile.name, image_url: profile.image_url)
            }
            else if let group = self.entity as? Group {
                self.addInfo(name: group.name, image_url: group.image_url)
            }
        }
    }
    
    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(entity: Any) {
        self.init(style: .default, reuseIdentifier: EntitySearchCell.reuse_identifier)
        self.entity = entity
        
        if let profile = self.entity as? Profile {
            self.textLabel?.text = profile.name
            
            if let url = profile.image_url {
                self.imageView?.kf.setImage(with: URL(string: url))
            }
            else {
                self.imageView?.image = #imageLiteral(resourceName: "default_user_image")
            }
        }
        else if let group = self.entity as? Group {
            self.textLabel?.text = group.name
        }
    }
    
    private func clear() {
        self.image_view.image = nil
        self.label.text = nil
    }
    
    private func addInfo(name: String, image_url: String?) {
        self.label.text = name
        
        if let url = image_url {
            self.image_view.kf.setImage(with: URL(string: url))
        }
        else {
            self.image_view.image = #imageLiteral(resourceName: "default_user_image")
        }
        
        self.addSubview(image_view)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
