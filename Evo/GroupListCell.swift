//
//  GroupListCell.swift
//  Evo
//
//  Created by Admin on 7/1/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import LBTAComponents

class GroupListCell: DatasourceCell {
    
    var group: Group!
    
    override var datasourceItem: Any? {
        didSet {
            guard let group = datasourceItem as? Group else { return }
            self.group = group
            
            if let image_url = group.image_url {
                self.image_view.kf.setImage(with: URL(string: image_url))
            }
            else {
                self.image_view.image = #imageLiteral(resourceName: "default_user_image")
            }
            
            self.name_label.text = group.name
        }
    }
    
    override func setupViews() {
        super.setupViews()
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = .EVO_border_gray
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewGroupPage(gesture_recognizer:))))
        
        self.addSubview(image_view)
        self.addSubview(name_label)
        
        image_view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        image_view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        image_view.widthAnchor.constraint(equalToConstant: GroupListCell.size_of_group_image).isActive = true
        image_view.heightAnchor.constraint(equalToConstant: GroupListCell.size_of_group_image).isActive = true
        
        name_label.leftAnchor.constraint(equalTo: image_view.rightAnchor, constant: 10).isActive = true
        name_label.centerYAnchor.constraint(equalTo: image_view.centerYAnchor).isActive = true
        name_label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
    }
    
    /* views */
    
    static let size_of_group_image: CGFloat = 65
    
    lazy var image_view: UIImageView = {
        let image_view = UIImageView()
        image_view.layer.borderColor = UIColor.black.cgColor
        image_view.layer.borderWidth = 1
        image_view.layer.masksToBounds = true
        image_view.layer.cornerRadius = GroupListCell.size_of_group_image / 2.0
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.isUserInteractionEnabled = true
        // image_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewGroupPage(gesture_recognizer:))))
        return image_view
    }()
    
    let name_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 16)
        label.textColor = .EVO_text_gray
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func viewGroupPage(gesture_recognizer: UIGestureRecognizer) {
        if gesture_recognizer.state == .ended {
            
            for controller in self.controller!.navigationController!.viewControllers as Array {
                
                if controller is GroupController && (controller as! GroupController).group.id == group.id {
                    self.controller!.navigationController!.popToViewController(controller, animated: true)
                    return
                }
            }
            
            (self.controller! as! EntityListController).navigationController?.pushViewController(GroupController(of: group), animated: true)
        }
    }
    
}
