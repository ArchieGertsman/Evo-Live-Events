//
//  GroupsCollectionViewController.swift
//  Evo
//
//  Created by Admin on 8/22/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit


/* controller that displays a collection of groups */
class GroupsCollectionViewController: UICollectionViewController {
    
    private static let reuse_identifier = "GroupCell"
    var groups = [Group]() // collection of groups to be displayed
    
    // c-tor which specifies the CollectionView's layout
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // Register cell classes
        self.collectionView!.register(GroupCell.self, forCellWithReuseIdentifier: GroupsCollectionViewController.reuse_identifier)
        self.collectionView!.backgroundColor = .clear
    }
    
    // make sure the navigation bar is hidden when this controller is open
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

/* extension which implements CollectionView methods */
extension GroupsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // only 1 section of groups
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count // number of groups
    }
    
    // set up each group's cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupsCollectionViewController.reuse_identifier, for: indexPath) as! GroupCell
        
        cell.group = self.groups[indexPath.row]
        
        // set group's icon
        if let image_url = self.groups[indexPath.row].image_url {
            cell.image_view.kf.setImage(with: URL(string: image_url))
        }
        else {
            // if the group doesn't have one then use the default one
            cell.image_view.image = #imageLiteral(resourceName: "default_user_image")
        }
        
        // split the group's name into two lines if it's long
        
        var str = self.groups[indexPath.row].name
        let length = str.characters.count
        
        let splitRange = str.range(of: " ", options: String.CompareOptions.literal, range: str.index(str.startIndex, offsetBy: length / 2)..<str.endIndex, locale: nil) // finds first space after halfway mark
        
        if let splitRange = splitRange, length >= 12 {
            let firstLine = String(str[..<splitRange.lowerBound]) // "Hello, label, here is"
            let secondLine = String(str[splitRange.upperBound...]) // "some variable text"
            
            cell.label.text = firstLine + "\n" + secondLine
        }
        else {
            cell.label.text = str
        }
        
        return cell
    }
    
    // if a group is clicked then open that group's page
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GroupCell
        self.viewController?.navigationController?.pushViewController(GroupController(of: cell.group), animated: true)
    }
    
    // specify the dimensions of each group cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3.0 - 20, height: collectionView.frame.width / 3.0 + 20)
    }
    
    // some more visual stuff
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 60, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

}

/* class which is used to represent a group as a cell in the collection view */
fileprivate class GroupCell: UICollectionViewCell {
    
    private static let size_of_image: CGFloat = 100
    var group: Group!
    
    let image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.cornerRadius = GroupCell.size_of_image / 2
        image_view.layer.masksToBounds = true
        image_view.layer.borderColor = UIColor.black.cgColor
        image_view.layer.borderWidth = 0.7
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .EVO_text_gray
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans", size: 14)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        
        self.addSubview(image_view)
        self.addSubview(label)
        
        self.image_view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.image_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.image_view.widthAnchor.constraint(equalToConstant: GroupCell.size_of_image).isActive = true
        self.image_view.heightAnchor.constraint(equalToConstant: GroupCell.size_of_image).isActive = true
        
        self.label.topAnchor.constraint(equalTo: self.image_view.bottomAnchor).isActive = true
        self.label.centerXAnchor.constraint(equalTo: self.image_view.centerXAnchor).isActive = true
        self.label.widthAnchor.constraint(equalTo: self.image_view.widthAnchor, constant: 20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
