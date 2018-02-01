//
//  CreateEventController.swift
//  Evo
//
//  Created by Admin on 4/28/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import GooglePlaces

typealias UsersDict = Dictionary<String, String> // maps uid to a user's name
typealias GroupsDict = Dictionary<String, String> // maps a gid to a group's name

class CreateEventController: UIViewController, UITextViewDelegate, UIScrollViewDelegate {
    
    var place: GMSPlace?
    var group: Group? // if this controller was opened from a group page then the group's info must be stored
    
    var name_height_constraint: NSLayoutConstraint!
    var description_height_constraint: NSLayoutConstraint!
    let scroll_view = UIScrollView()
    var start_time: Date?
    let tags_dropdown = UIPickerView()
    let ages_dropdown = UIPickerView()
    
    let tags_array: [Tag] = [
        .food_drink,
        .clubs,
        .sports,
        .education,
        .entertainment,
        .music,
        .social,
        .religious,
        .deals,
        .other
    ]
    let ages_array: [AgeRange] = [
        .all,
        .five_plus,
        .thirteen_plus,
        .eighteen_plus,
        .twenty_one_plus
    ]
    
    // if this page isn't called from a group then a list of the user's followings and groups shold be provided for invitation
    init(_ users_dict: UsersDict, _ groups_dict: GroupsDict) {
        self.invitation_token_view = InvitationTokenViewContainer(users_dict, groups_dict)
        self.invitation_token_view!.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // if this page is called from a group then the group's info should be passed to this c-tor
    init(_ group: Group) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initEvoStyle(title: "Create an Event")
        
        self.setDelegates()
        self.addSubviews()
        self.constrainViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* If not group event then make this a public event by default. Else, set it to be a group event.
         * The selection view is not actually visible if this is a group event. However, its data still exists
         * in memory, and it will still be read and used in `createEvent`
         */
        self.event_creation_method_selection_view.select(creation_method: self.group == nil ? .public_ : .group)
    }
    
    private func setDelegates() {
        self.name_text_view.delegate = self
        self.description_text_view.delegate = self
        self.starttime_text_field.delegate = self
        self.endtime_text_field.delegate = self
        
        self.tags_dropdown.delegate = self
        self.tags_dropdown.dataSource = self
        self.tags_text_field.delegate = self
        self.tags_text_field.inputView = self.tags_dropdown
        
        self.ages_dropdown.delegate = self
        self.ages_dropdown.dataSource = self
        self.ages_text_field.delegate = self
        self.ages_text_field.inputView = self.ages_dropdown
        
        self.event_creation_method_selection_view.controller = self
        
        self.scroll_view.delegate = self
    }
    
    private func addSubviews() {
        name_container_view.addSubview(name_container_title)
        name_container_view.addSubview(name_text_view)
        scroll_view.addSubview(name_container_view)
        
        description_container_view.addSubview(description_container_title)
        description_container_view.addSubview(description_text_view)
        scroll_view.addSubview(description_container_view)
        
        location_container_view.addSubview(location_container_title)
        location_container_view.addSubview(location_label)
        scroll_view.addSubview(location_container_view)
        
        time_container_view.addSubview(starttime_label)
        time_container_view.addSubview(time_separator)
        time_container_view.addSubview(endtime_label)
        time_container_view.addSubview(starttime_text_field)
        time_container_view.addSubview(endtime_text_field)
        scroll_view.addSubview(time_container_view)
        
        tags_container_view.addSubview(tags_container_title)
        tags_container_view.addSubview(tags_text_field)
        scroll_view.addSubview(tags_container_view)
        
        ages_container_view.addSubview(ages_container_title)
        ages_container_view.addSubview(ages_text_field)
        scroll_view.addSubview(ages_container_view)
        
        if let invitation_token_view = self.invitation_token_view {
            scroll_view.addSubview(event_creation_method_selection_view)
            scroll_view.addSubview(invitation_token_view)
        }
        scroll_view.addSubview(create_button)
        
        view.addSubview(scroll_view)
    }
    
    private func constrainViews() {
        self.constrainNameContainer()
        self.constrainDescriptionContainer()
        self.constrainLocationContainer()
        self.constrainTimeContainer()
        self.constrainTagsContainer()
        self.constrainAgesContainer()
        // invitation token view only exists if not group event
        if let _ = self.invitation_token_view {
            self.constrainEventCreationSelectionView()
            self.constrainInvitationTokenView()
        }
        self.constrainCreateButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scroll_view.frame = view.bounds
        scroll_view.contentSize = CGSize(width: self.view.frame.width, height: create_button.frame.maxY + 100)
    }
    
    /// name your event
    
    let name_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let name_container_title: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let name_text_view: UITextView = {
        let text_view = UITextView()
        text_view.backgroundColor = .clear
        text_view.textColor = .lightGray
        text_view.placeholder = "Insert name"
        text_view.text = text_view.placeholder
        text_view.font = UIFont(name: "OpenSans", size: 15)
        text_view.textContainerInset = UIEdgeInsets.zero
        text_view.textContainer.lineFragmentPadding = 0;
        text_view.character_limit = 40
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    /// describe your event
    
    let description_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let description_container_title: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let description_text_view: UITextView = {
        let text_view = UITextView()
        text_view.backgroundColor = .clear
        text_view.textColor = .lightGray
        text_view.placeholder = "Insert description"
        text_view.text = text_view.placeholder
        text_view.font = UIFont(name: "OpenSans", size: 15)
        text_view.textContainerInset = .zero
        text_view.textContainer.lineFragmentPadding = 0;
        text_view.character_limit = 114
        text_view.scrollsToTop = false
        text_view.alwaysBounceVertical = false
        text_view.bounces = false
        text_view.translatesAutoresizingMaskIntoConstraints = false
        return text_view
    }()
    
    /// set location
    
    lazy var location_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.chooseLocation)))
        return view
    }()
    
    let location_container_title: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    internal static let default_location_text = "Tap anywhere to search"
    internal static let location_error_message = "Error: Location services are disabled for Evo in your device settings."
    
    lazy var location_label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = CreateEventController.default_location_text
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "OpenSans", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// set time
    
    let time_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let starttime_label: UILabel = {
        let label = UILabel()
        label.text = "Starts"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let endtime_label: UILabel = {
        let label = UILabel()
        label.text = "Ends"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let time_separator: UIView = {
        let view = UIView()
        view.backgroundColor = .EVO_border_gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var starttime_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .lightGray
        text_field.font = UIFont(name: "OpenSans", size: 15)
        text_field.placeholder = "Insert time"
        text_field.text = text_field.placeholder
        text_field.textAlignment = .right
        
        let date_picker = UIDatePicker()
        date_picker.minimumDate = Date()
        var max = Calendar.current.date(byAdding: .hour, value: 17, to: Date())!
        max = Calendar.current.date(byAdding: .minute, value: 59, to: max)!
        date_picker.maximumDate = max
        
        date_picker.datePickerMode = .dateAndTime
        date_picker.addTarget(self, action: #selector(handleStarttimePicker(sender:)), for: .valueChanged)
        text_field.inputView = date_picker
        
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    lazy var endtime_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .lightGray
        text_field.font = UIFont(name: "OpenSans", size: 15)
        text_field.placeholder = "Insert time"
        text_field.text = text_field.placeholder
        text_field.textAlignment = .right
        // text_field.isEnabled = false
        
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    /// add tags
    
    let tags_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tags_container_title: UILabel = {
        let label = UILabel()
        label.text = "Tags"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tags_text_field: UITextField = {
        let text_field = UITextField()
        text_field.placeholder = "No tag selected"
        text_field.textColor = UIColor.lightGray
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    /// ages
    
    let ages_container_view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let ages_container_title: UILabel = {
        let label = UILabel()
        label.text = "Ages"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ages_text_field: UITextField = {
        let text_field = UITextField()
        text_field.placeholder = "No ages selected"
        text_field.textColor = UIColor.lightGray
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    let event_creation_method_selection_view = EventCreationMethodSelectionView()
    var invitation_token_view: InvitationTokenViewContainer?
    
    let create_button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.EVO_blue
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 24)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Create", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        return button
    }()
    
    
    /// constraints
    
    func constrainNameContainer() {
        // container
        name_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        name_container_view.topAnchor.constraint(equalTo: scroll_view.topAnchor, constant: 15).isActive = true
        name_container_view.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        // title
        name_container_title.leftAnchor.constraint(equalTo: name_container_view.leftAnchor, constant: 10).isActive = true
        name_container_title.topAnchor.constraint(equalTo: name_container_view.topAnchor, constant: 6).isActive = true
        
        // text view
        name_text_view.leftAnchor.constraint(equalTo: name_container_title.leftAnchor).isActive = true
        name_text_view.topAnchor.constraint(equalTo: name_container_title.bottomAnchor, constant: 3).isActive = true
        name_height_constraint = name_text_view.heightAnchor.constraint(equalToConstant: 40)
        name_height_constraint.isActive = true
        name_text_view.rightAnchor.constraint(equalTo: name_container_view.rightAnchor, constant: -10).isActive = true
        
        name_container_view.bottomAnchor.constraint(equalTo: name_text_view.bottomAnchor, constant: -5).isActive = true
    }
    
    func constrainDescriptionContainer() {
        // container
        description_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        description_container_view.topAnchor.constraint(equalTo: name_container_view.bottomAnchor, constant: 15).isActive = true
        description_container_view.widthAnchor.constraint(equalTo: name_container_view.widthAnchor).isActive = true
        
        // title
        description_container_title.leftAnchor.constraint(equalTo: description_container_view.leftAnchor, constant: 10).isActive = true
        description_container_title.topAnchor.constraint(equalTo: description_container_view.topAnchor, constant: 6).isActive = true
        
        // text view
        description_text_view.leftAnchor.constraint(equalTo: description_container_title.leftAnchor).isActive = true
        description_text_view.topAnchor.constraint(equalTo: description_container_title.bottomAnchor, constant: 5).isActive = true
        self.description_height_constraint = description_text_view.heightAnchor.constraint(equalToConstant: 40)
        self.description_height_constraint.isActive = true
        description_text_view.rightAnchor.constraint(equalTo: description_container_view.rightAnchor, constant: -10).isActive = true
        
        description_container_view.bottomAnchor.constraint(equalTo: description_text_view.bottomAnchor, constant: -5).isActive = true
    }
    
    func constrainLocationContainer() {
        // container
        location_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        location_container_view.topAnchor.constraint(equalTo: description_container_view.bottomAnchor, constant: 15).isActive = true
        location_container_view.widthAnchor.constraint(equalTo: description_container_view.widthAnchor).isActive = true
        
        // title
        location_container_title.leftAnchor.constraint(equalTo: location_container_view.leftAnchor, constant: 10).isActive = true
        location_container_title.topAnchor.constraint(equalTo: location_container_view.topAnchor, constant: 6).isActive = true
        
        // location label
        location_label.leftAnchor.constraint(equalTo: location_container_title.leftAnchor).isActive = true
        location_label.topAnchor.constraint(equalTo: location_container_title.bottomAnchor, constant: 3).isActive = true
        location_label.rightAnchor.constraint(equalTo: location_container_view.rightAnchor).isActive = true
        
        location_container_view.bottomAnchor.constraint(equalTo: location_label.bottomAnchor, constant: 10).isActive = true
    }
    
    func constrainTimeContainer() {
        // container
        time_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        time_container_view.topAnchor.constraint(equalTo: location_container_view.bottomAnchor, constant: 20).isActive = true
        time_container_view.widthAnchor.constraint(equalTo: location_container_view.widthAnchor).isActive = true
        time_container_view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // separator
        time_separator.leftAnchor.constraint(equalTo: time_container_view.leftAnchor).isActive = true
        time_separator.rightAnchor.constraint(equalTo: time_container_view.rightAnchor).isActive = true
        time_separator.centerYAnchor.constraint(equalTo: time_container_view.centerYAnchor).isActive = true
        time_separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // labels
        starttime_label.leftAnchor.constraint(equalTo: time_container_view.leftAnchor, constant: 10).isActive = true
        starttime_label.topAnchor.constraint(equalTo: time_container_view.topAnchor, constant: 6).isActive = true
        
        endtime_label.leftAnchor.constraint(equalTo: starttime_label.leftAnchor).isActive = true
        endtime_label.bottomAnchor.constraint(equalTo: time_container_view.bottomAnchor, constant: -10).isActive = true
        
        // text fields
        starttime_text_field.rightAnchor.constraint(equalTo: time_container_view.rightAnchor, constant: -10).isActive = true
        starttime_text_field.centerXAnchor.constraint(equalTo: starttime_label.centerXAnchor).isActive = true
        starttime_text_field.centerYAnchor.constraint(equalTo: starttime_label.centerYAnchor).isActive = true
        starttime_text_field.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        endtime_text_field.rightAnchor.constraint(equalTo: time_container_view.rightAnchor, constant: -10).isActive = true
        endtime_text_field.centerXAnchor.constraint(equalTo: endtime_label.centerXAnchor).isActive = true
        endtime_text_field.centerYAnchor.constraint(equalTo: endtime_label.centerYAnchor).isActive = true
        endtime_text_field.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func constrainTagsContainer() {
        // container
        tags_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tags_container_view.topAnchor.constraint(equalTo: time_container_view.bottomAnchor, constant: 15).isActive = true
        tags_container_view.widthAnchor.constraint(equalTo: time_container_view.widthAnchor).isActive = true
        
        // title
        tags_container_title.leftAnchor.constraint(equalTo: tags_container_view.leftAnchor, constant: 10).isActive = true
        tags_container_title.topAnchor.constraint(equalTo: tags_container_view.topAnchor, constant: 6).isActive = true
        
        // text view
        tags_text_field.leftAnchor.constraint(equalTo: tags_container_title.leftAnchor).isActive = true
        tags_text_field.topAnchor.constraint(equalTo: tags_container_title.bottomAnchor, constant: 3).isActive = true
        tags_text_field.heightAnchor.constraint(equalToConstant: tags_text_field.intrinsicContentSize.height).isActive = true
        tags_text_field.rightAnchor.constraint(equalTo: tags_container_title.rightAnchor, constant: -10).isActive = true
        
        tags_container_view.bottomAnchor.constraint(equalTo: tags_text_field.bottomAnchor, constant: 10).isActive = true
    }
    
    func constrainAgesContainer() {
        // container
        ages_container_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ages_container_view.topAnchor.constraint(equalTo: tags_container_view.bottomAnchor, constant: 15).isActive = true
        ages_container_view.widthAnchor.constraint(equalTo: tags_container_view.widthAnchor).isActive = true
        
        // title
        ages_container_title.leftAnchor.constraint(equalTo: ages_container_view.leftAnchor, constant: 10).isActive = true
        ages_container_title.topAnchor.constraint(equalTo: ages_container_view.topAnchor, constant: 6).isActive = true
        
        // text view
        ages_text_field.leftAnchor.constraint(equalTo: ages_container_title.leftAnchor).isActive = true
        ages_text_field.topAnchor.constraint(equalTo: ages_container_title.bottomAnchor, constant: 3).isActive = true
        ages_text_field.heightAnchor.constraint(equalToConstant: ages_text_field.intrinsicContentSize.height).isActive = true
        ages_text_field.rightAnchor.constraint(equalTo: ages_container_title.rightAnchor, constant: -10).isActive = true
        
        ages_container_view.bottomAnchor.constraint(equalTo: ages_text_field.bottomAnchor, constant: 10).isActive = true
    }
    
    func constrainEventCreationSelectionView() {
        event_creation_method_selection_view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        event_creation_method_selection_view.topAnchor.constraint(equalTo: ages_container_view.bottomAnchor, constant: 15).isActive = true
        event_creation_method_selection_view.widthAnchor.constraint(equalTo: ages_container_view.widthAnchor).isActive = true
        event_creation_method_selection_view.bottomAnchor.constraint(equalTo: event_creation_method_selection_view.bottom_anchor_of_collection_view, constant: 10).isActive = true
    }
    
    func constrainInvitationTokenView() {
        invitation_token_view?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        invitation_token_view?.topAnchor.constraint(equalTo: event_creation_method_selection_view.bottomAnchor, constant: 5).isActive = true
        invitation_token_view?.widthAnchor.constraint(equalTo: event_creation_method_selection_view.widthAnchor).isActive = true
        invitation_token_view?.addTokenView()
    }
    
    var create_button_top_constraint: NSLayoutConstraint!
    
    func constrainCreateButton() {
        if let invitation_token_view = self.invitation_token_view {
            create_button_top_constraint = create_button.topAnchor.constraint(equalTo: invitation_token_view.token_view.bottomAnchor, constant: 15)
            create_button_top_constraint.isActive = true
        }
        else {
            create_button_top_constraint = create_button.topAnchor.constraint(equalTo: ages_container_view.bottomAnchor, constant: 15)
            create_button_top_constraint.isActive = true
        }
        create_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        create_button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        create_button.widthAnchor.constraint(equalTo: ages_container_view.widthAnchor).isActive = true
    }
    
}

extension CreateEventController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 // there are 4 types of events
    }
    
    // set up each cell in selection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCreationMethodCell.reuse_identifier, for: indexPath) as! EventCreationMethodCell
        cell.label.text = self.event_creation_method_selection_view.creation_methods_array[indexPath.row].rawValue
        cell.label.frame = cell.bounds
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let invitation_token_view = self.invitation_token_view else { return } // invitation_token_view is only present if not group event
        
        let cell = collectionView.cellForItem(at: indexPath) as! EventCreationMethodCell
        cell.label.textColor = .EVO_blue // set selected cell's text to EVO_blue
        
        let method = EventCreationMethod(rawValue: cell.label.text!)! // get selected method
        
        switch method {
        case .public_, .my_crowds, .invite_only:
            if invitation_token_view.mode != .user_invitation {
                // avoid resetting the same mode because `invitation_token_view.mode` has `didSet` functionality
                invitation_token_view.mode = .user_invitation
            }
        case .group: invitation_token_view.mode = .group_post
        }
        
        /* invitation token view may resize depending on the mode, so update the constraint of the controller's create button,
         * which is constrained to the bottom of the token view */
        create_button_top_constraint.isActive = false
        create_button_top_constraint = create_button.topAnchor.constraint(equalTo: invitation_token_view.token_view.bottomAnchor, constant: 15)
        create_button_top_constraint.isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EventCreationMethodCell
        cell.label.textColor = .EVO_text_gray // set deselected cell to have gray text
    }
    
    // some layout stuff
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4.0, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}

enum EventCreationMethod: String {
    case public_ = "Public"
    case my_crowds = "My Crowds"
    case invite_only = "Invite Only"
    case group = "Groups"
}

/* area where the user selects the whether the event is public, my crowds, invite only, or group */
class EventCreationMethodSelectionView: UIView {
    
    var controller: CreateEventController! {
        didSet {
            self.collection_view.delegate = self.controller
            self.collection_view.dataSource = self.controller
        }
    }
    
    var collection_view: UICollectionView!
    
    let creation_methods_array: [EventCreationMethod] = [
        .public_,
        .my_crowds,
        .invite_only,
        .group
    ]
    
    private let title_label: UILabel = {
        let label = UILabel()
        label.text = "Type"
        label.textColor = .EVO_text_gray
        label.font = UIFont(name: "OpenSans", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var selected_creation_method: EventCreationMethod {
        return self.creation_methods_array[self.collection_view.indexPathsForSelectedItems![0].row]
    }
    
    var bottom_anchor_of_collection_view: NSLayoutYAxisAnchor {
        return self.collection_view.bottomAnchor
    }
    
    init() {
        super.init(frame: .zero)
        self.setUpContainerUI()
        
        self.collection_view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.collection_view.register(EventCreationMethodCell.self, forCellWithReuseIdentifier: EventCreationMethodCell.reuse_identifier)
        self.collection_view.backgroundColor = .clear
        self.collection_view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.title_label)
        self.addSubview(self.collection_view)
        
        self.title_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        self.title_label.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        
        self.collection_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.collection_view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.collection_view.topAnchor.constraint(equalTo: self.title_label.bottomAnchor, constant: 5).isActive = true
        self.collection_view.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    required init(title: String) {
        fatalError("init(title:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpContainerUI() {
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.EVO_border_gray.cgColor
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // this function programatically mimics what happens when someone taps on an option
    func select(creation_method: EventCreationMethod) {
        let selection_idx = self.creation_methods_array.index(of: creation_method)!
        self.collection_view.selectItem(at: IndexPath(row: selection_idx, section: 0), animated: true, scrollPosition: .centeredVertically)
        if let cell = self.collection_view.cellForItem(at: IndexPath(row: selection_idx, section: 0)) as? EventCreationMethodCell {
            cell.label.textColor = .EVO_blue
        }
    }
    
}

/* custom cell class which will be used in the collection view of EventCreationMethodSelectionView */
class EventCreationMethodCell: UICollectionViewCell {
    
    static let reuse_identifier = "EventCreationMethodCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .EVO_text_gray
        label.textAlignment = .center
        label.font = UIFont(name: "OpenSans", size: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        
        self.addSubview(label)
        self.label.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/* container that contains and manages the token view */
class InvitationTokenViewContainer: UIView {
    
    enum Mode {
        case user_invitation // lists the people that the current is following
        case group_post // lists the groups that the current user is in
    }
    
    var mode: Mode = .user_invitation {
        didSet {
            self.token_view.isHidden = true
            
            switch mode {
            case .user_invitation: self.token_view = TokenView(user_names, field_name: "Invite")
            case .group_post:
                self.token_view = TokenView(group_names, field_name: "Add To")
                self.token_view.max_number_of_tokens = 1 // if it's a group post then it can only be posted to 1 group
            }
            
            self.addTokenView()
        }
    }
    
    private var bottom_anchor_constraint: NSLayoutConstraint!
    
    var users_dict = UsersDict()
    var groups_dict = GroupsDict()
    
    private var user_names: [String] {
        return Array(users_dict.keys)
    }
    private var group_names: [String] {
        return Array(groups_dict.keys)
    }
    
    var token_view: TokenView!
    
    required init(_ users_dict: UsersDict, _ groups_dict: GroupsDict) {
        self.users_dict = users_dict
        self.groups_dict = groups_dict
        
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.token_view = TokenView(Array(users_dict.keys), field_name: "Invite")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ names: [String], field_name: String) {
        fatalError("init(_:field_name:) has not been implemented")
    }
    
    // adds a token view to this container. If there is already a token view then this function scraps it and adds a new one
    func addTokenView() {
        
        if let constraint = self.bottom_anchor_constraint {
            constraint.isActive = false
        }
        
        self.token_view.is_border_enabled = true
        self.token_view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.token_view)
        
        self.token_view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.token_view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.token_view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.bottom_anchor_constraint = self.bottomAnchor.constraint(equalTo: self.token_view.bottomAnchor)
        self.bottom_anchor_constraint.isActive = true
    }
    
}

