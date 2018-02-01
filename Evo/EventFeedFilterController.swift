//
//  EventFeedFilterController.swift
//  Evo
//
//  Created by Admin on 8/6/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit

// here's all the data the filter manages
struct Filter {
    var earliest_time: Date?
    var latest_time: Date?
    var distance: UInt
    
    var age_index_paths: [IndexPath]?
    var age_ranges: [AgeRange]
    
    var tag_index_paths: [IndexPath]?
    var tags: [Tag]
}

// implement in controllers that use the filter
protocol EventFeedFilterControllerDelegate: class {
    func updateFilter(with filter: Filter?)
    func changeFilterButtonColor(to color: UIColor)
}

class EventFeedFilterController: UIViewController, UIScrollViewDelegate {
    
    weak var delegate: EventFeedFilterControllerDelegate?
    var filter: Filter?
    var did_fill_information = false
    
    let scroll_view = UIScrollView()
    fileprivate var time_view = TimeView()
    fileprivate var distance_view = DistanceView()
    fileprivate var ages_view = AgesView()
    fileprivate var tags_view = TagsView()
    lazy var reset_button: UIButton = { // tap this buttno to clean and disable the feed
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.reset), for: .touchUpInside)
        return button
    }()
    
    convenience init(with filter: Filter) {
        self.init(nibName: nil, bundle: nil)
        self.filter = filter
    }
    
    // the following two functions set everything up. All the helper functions are below
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavBarItems()
        self.view.backgroundColor = OverlayMenuController.translucent_background_color
        self.resetViews()
        self.fillInItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setUpScrollView()
        self.setUpDistanceSlider()
        
        if !self.did_fill_information {
            self.fillInCollectionViews()
        }
    }
    
    private func setUpNavBarItems() {
        self.initEvoStyle(title: "Filter")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissWithoutCompletionFade)) // cancel button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(self.updateFilter))
    }
    
    func setUpViews() {
        self.setDelegates()
        self.disableAutoresizingMasks()
        self.addSubViews()
        self.constrainViews()
    }
    
    private func setDelegates() {
        self.scroll_view.delegate = self
        self.time_view.controller = self
        self.distance_view.controller = self
        self.ages_view.controller = self
        self.tags_view.controller = self
    }
    
    private func disableAutoresizingMasks() {
        self.time_view.translatesAutoresizingMaskIntoConstraints = false
        self.distance_view.translatesAutoresizingMaskIntoConstraints = false
        self.ages_view.translatesAutoresizingMaskIntoConstraints = false
        self.tags_view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubViews() {
        self.scroll_view.addSubview(self.time_view)
        self.scroll_view.addSubview(self.distance_view)
        self.scroll_view.addSubview(self.ages_view)
        self.scroll_view.addSubview(self.tags_view)
        self.scroll_view.addSubview(self.reset_button)
        self.view.addSubview(scroll_view)
    }
    
    private func constrainViews() {
        self.constrainTimeView()
        self.constrainDistanceView()
        self.constrainAgesView()
        self.constrainTagsView()
        self.constrainResetButton()
    }
    
    private func constrainTimeView() {
        self.time_view.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        self.time_view.topAnchor.constraint(equalTo: self.scroll_view.topAnchor,constant: 20).isActive = true
        self.time_view.widthAnchor.constraint(equalTo: self.scroll_view.widthAnchor).isActive = true
        self.time_view.bottomAnchor.constraint(equalTo: self.time_view.getBottomAnchor(), constant: 10).isActive = true
    }
    
    private func constrainDistanceView() {
        self.distance_view.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        self.distance_view.topAnchor.constraint(equalTo: self.time_view.bottomAnchor, constant: 20).isActive = true
        self.distance_view.widthAnchor.constraint(equalTo: self.scroll_view.widthAnchor).isActive = true
        self.distance_view.bottomAnchor.constraint(equalTo: self.distance_view.getBottomAnchor(), constant: 10).isActive = true
    }
    
    private func constrainAgesView() {
        self.ages_view.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        self.ages_view.topAnchor.constraint(equalTo: self.distance_view.bottomAnchor, constant: 20).isActive = true
        self.ages_view.widthAnchor.constraint(equalTo: self.scroll_view.widthAnchor).isActive = true
        self.ages_view.bottomAnchor.constraint(equalTo: self.ages_view.getBottomAnchor(), constant: 10).isActive = true
    }
    
    private func constrainTagsView() {
        self.tags_view.centerXAnchor.constraint(equalTo: self.scroll_view.centerXAnchor).isActive = true
        self.tags_view.topAnchor.constraint(equalTo: self.ages_view.bottomAnchor, constant: 20).isActive = true
        self.tags_view.widthAnchor.constraint(equalTo: self.scroll_view.widthAnchor).isActive = true
        self.tags_view.bottomAnchor.constraint(equalTo: self.tags_view.getBottomAnchor(), constant: 10).isActive = true
    }
    
    private func constrainResetButton() {
        self.reset_button.rightAnchor.constraint(equalTo: self.time_view.rightAnchor, constant: -10).isActive = true
        self.reset_button.centerYAnchor.constraint(equalTo: self.time_view.title_label.centerYAnchor).isActive = true
        self.reset_button.widthAnchor.constraint(equalToConstant: self.reset_button.intrinsicContentSize.width + 5).isActive = true
        self.reset_button.heightAnchor.constraint(equalToConstant: self.reset_button.intrinsicContentSize.height).isActive = true
    }
    
    private func setUpScrollView() {
        self.scroll_view.frame = self.view.bounds
        self.scroll_view.contentSize = CGSize(width: self.view.frame.width, height: self.tags_view.frame.maxY + 80)
    }
    
    private func setUpDistanceSlider() {
        guard let handle_view = self.distance_view.distance_slider.subviews.last as? UIImageView else { return }
        self.distance_view.distance_slider.addDistanceLabel(position: .above, handle_view)
    }
    
    private func fillInItems() {
        guard let filter = self.filter else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd h:mm a"
        
        if let start_time = filter.earliest_time {
            self.time_view.start_time_text_field.text = "\(formatter.string(from: start_time))"
            (self.time_view.start_time_text_field.inputView as! UIDatePicker).setDate(start_time, animated: true)
        }
        
        if let end_time = filter.latest_time {
            self.time_view.end_time_text_field.text = "\(formatter.string(from: end_time))"
            (self.time_view.end_time_text_field.inputView as! UIDatePicker).setDate(end_time, animated: true)
        }
        
        self.distance_view.distance_slider.value = Float(filter.distance)
    }
    
    private func fillInCollectionViews() {
        guard let filter = self.filter else { return }
        
        if let paths = filter.age_index_paths {
            for path in paths {
                self.ages_view.collection_view.selectItem(at: path, animated: true, scrollPosition: .centeredVertically)
                
                if let cell = self.ages_view.collection_view.cellForItem(at: path) as? AgeCell {
                    cell.shows_border = true
                }
                else {
                    print("no cell [fillInCollectionViews]")
                }
            }
        }
        
        if let paths = filter.tag_index_paths {
            for path in paths {
                self.tags_view.table_view.selectRow(at: path, animated: true, scrollPosition: .none)
                self.tags_view.table_view.cellForRow(at: path)?.accessoryType = .checkmark
            }
        }
        
        self.did_fill_information = true
    }
    
    @objc func updateFilter() {
        var earliest_time: Date?
        var latest_time: Date?
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd h:mm a"
        
        if let time = self.time_view.start_time_text_field.text, time != self.time_view.start_time_text_field.placeholder {
            var date_components = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: formatter.date(from: time)!)
            let year = Calendar.current.dateComponents([.year], from: Date()).year
            date_components.setValue(year, for: .year)
            earliest_time = Calendar.current.date(from: date_components)
        }
        if let time = self.time_view.end_time_text_field.text, time != self.time_view.end_time_text_field.placeholder {
            var date_components = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: formatter.date(from: time)!)
            let year = Calendar.current.dateComponents([.year], from: Date()).year
            date_components.setValue(year, for: .year)
            latest_time = Calendar.current.date(from: date_components)
        }
        
        let distance = self.distance_view.distance_slider.distance
        
        let ages = self.ages_view.getSelectedAgeRanges()
        let tags = self.tags_view.getSelectedTags()
        
        let filter = Filter(earliest_time: earliest_time, latest_time: latest_time, distance: distance, age_index_paths: self.ages_view.collection_view.indexPathsForSelectedItems, age_ranges: ages, tag_index_paths: self.tags_view.table_view.indexPathsForSelectedRows, tags: tags)
        
        self.delegate?.updateFilter(with: filter)
        self.delegate?.changeFilterButtonColor(to: UIColor(r: 117, g: 211, b:255))
        self.dismissWithoutCompletionFade()
    }
    
    @objc func reset() {
        self.filter = nil
        self.delegate?.changeFilterButtonColor(to: .white)
        self.delegate?.updateFilter(with: nil)
        
        self.resetViews()
    }
    
    private func resetViews() {
        for subview in self.scroll_view.subviews {
            subview.removeConstraints(subview.constraints)
            subview.removeFromSuperview()
        }
        
        self.time_view = TimeView()
        self.distance_view = DistanceView()
        self.ages_view = AgesView()
        self.tags_view = TagsView()
        
        self.setUpViews()
    }
    
    @objc func handleStartTimePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm a"
        print(dateFormatter.string(from: sender.date))
        self.time_view.start_time_text_field.text = "\(dateFormatter.string(from: sender.date))"
    }
    
    @objc func handleEndTimePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm a"
        self.time_view.end_time_text_field.text = "\(dateFormatter.string(from: sender.date))"
    }
    
}

extension EventFeedFilterController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd h:mm a"
        let current_date = Date()
        
        switch textField {
        case self.time_view.start_time_text_field:
            if self.time_view.start_time_text_field.text == self.time_view.start_time_text_field.placeholder {
                
                if let start_time = self.filter?.earliest_time {
                    self.time_view.start_time_text_field.text = "\(dateFormatter.string(from: start_time))"
                    (self.time_view.start_time_text_field.inputView as! UIDatePicker).setDate(start_time, animated: true)
                }
                else {
                    self.time_view.start_time_text_field.text = "\(dateFormatter.string(from: current_date))"
                    (self.time_view.start_time_text_field.inputView as! UIDatePicker).setDate(current_date, animated: true)
                }
            }
            
        case self.time_view.end_time_text_field:
            if self.time_view.end_time_text_field.text == self.time_view.end_time_text_field.placeholder {
                
                if let end_time = self.filter?.latest_time {
                    self.time_view.end_time_text_field.text = "\(dateFormatter.string(from: end_time))"
                    (self.time_view.end_time_text_field.inputView as! UIDatePicker).setDate(end_time, animated: true)
                }
                else {
                    self.time_view.end_time_text_field.text = "\(dateFormatter.string(from: current_date))"
                    (self.time_view.end_time_text_field.inputView as! UIDatePicker).setDate(current_date, animated: true)
                }
            }
            
        default: break
        }
    }
    
}

/* extension that implements collectionview functionality for the AGES VIEW */
extension EventFeedFilterController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 // 5 age optiosn
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AgeCell", for: indexPath) as! AgeCell
        cell.label.text = self.ages_view.ages_array[indexPath.row].rawValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AgeCell
        cell.shows_border = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AgeCell
        cell.shows_border = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 10.0 - 20.0) / 5.0, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0;
    }
    
}

/* extension that implements tableview functionality for the TAGS VIEW */
extension EventFeedFilterController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tags_view.cells[indexPath.row]
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
}

/* each section in the filter controller derives from this */
fileprivate class FilterSectionView: UIView {
    
    weak var controller: EventFeedFilterController!
    
    // each section has a title. Here it is
    let title_label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 25)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init(title: String) {
        super.init(frame: .zero)
        self.title_label.text = title
        
        self.addSubview(self.title_label)
        
        title_label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        title_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    func getBottomAnchor() -> NSLayoutYAxisAnchor {
        fatalError("getBottomAnchor not overriden")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate class TimeView: FilterSectionView {
    
    override var controller: EventFeedFilterController! {
        didSet {
            self.start_time_text_field.delegate = self.controller
            self.end_time_text_field.delegate = self.controller
        }
    }
    
    let start_time_label: UILabel = {
        let label = UILabel()
        label.text = "After:"
        label.font = UIFont(name: "GothamRounded-Medium", size: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let end_time_label: UILabel = {
        let label = UILabel()
        label.text = "Before:"
        label.font = UIFont(name: "GothamRounded-Medium", size: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var start_time_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .white
        text_field.font = UIFont(size: 16)
        text_field.placeholder = "Start Time"
        text_field.text = text_field.placeholder
        text_field.textAlignment = .right
        
        let start_date_picker = UIDatePicker()
        start_date_picker.datePickerMode = .dateAndTime
        start_date_picker.addTarget(self.controller, action: #selector(self.controller.handleStartTimePicker(sender:)), for: .valueChanged)
        text_field.inputView = start_date_picker
        
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    lazy var end_time_text_field: UITextField = {
        let text_field = UITextField()
        text_field.textColor = .white
        text_field.font = UIFont(size: 16)
        text_field.placeholder = "End Time"
        text_field.text = text_field.placeholder
        text_field.textAlignment = .right
        
        let end_date_picker = UIDatePicker()
        end_date_picker.datePickerMode = .dateAndTime
        end_date_picker.addTarget(self.controller, action: #selector(self.controller.handleEndTimePicker(sender:)), for: .valueChanged)
        text_field.inputView = end_date_picker
        
        text_field.translatesAutoresizingMaskIntoConstraints = false
        return text_field
    }()
    
    
    init() {
        super.init(title: "Time")

        self.addSubviews()
        self.constrainViews()
    }
    
    private func addSubviews() {
        self.addSubview(self.start_time_label)
        self.addSubview(self.start_time_text_field)
        self.addSubview(self.end_time_label)
        self.addSubview(self.end_time_text_field)
    }
    
    private func constrainViews() {
        self.start_time_label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        self.start_time_label.topAnchor.constraint(equalTo: self.title_label.bottomAnchor, constant: 10).isActive = true
        
        self.start_time_text_field.centerYAnchor.constraint(equalTo: self.start_time_label.centerYAnchor).isActive = true
        self.start_time_text_field.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        self.start_time_text_field.widthAnchor.constraint(equalToConstant: 120).isActive = true
        self.start_time_text_field.heightAnchor.constraint(equalToConstant: start_time_text_field.intrinsicContentSize.height).isActive = true
        
        self.end_time_label.leftAnchor.constraint(equalTo: self.start_time_label.leftAnchor).isActive = true
        self.end_time_label.topAnchor.constraint(equalTo: self.start_time_label.bottomAnchor, constant: 10).isActive = true
        
        self.end_time_text_field.centerYAnchor.constraint(equalTo: self.end_time_label.centerYAnchor).isActive = true
        self.end_time_text_field.rightAnchor.constraint(equalTo: self.start_time_text_field.rightAnchor).isActive = true
        self.end_time_text_field.widthAnchor.constraint(equalToConstant: 120).isActive = true
        self.end_time_text_field.heightAnchor.constraint(equalToConstant: end_time_text_field.intrinsicContentSize.height).isActive = true
    }
    
    override func getBottomAnchor() -> NSLayoutYAxisAnchor {
        return self.end_time_label.bottomAnchor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(title: String) {
        fatalError("init(title:) has not been implemented")
    }
    
}

fileprivate class DistanceView: FilterSectionView {
    
    let miles_label: UILabel = {
        let label = UILabel()
        label.text = "(Miles)"
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Medium", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var distance_slider = CustomUISlider()
    
    init() {
        super.init(title: "Distance")
        
        self.distance_slider.value = default_event_radius.map { Float($0) } ?? 4.0
        
        self.addSubviews()
        self.constrainViews()
    }
    
    private func addSubviews() {
        self.addSubview(miles_label)
        self.addSubview(distance_slider)
    }
    
    private func constrainViews() {
        self.miles_label.topAnchor.constraint(equalTo: self.title_label.bottomAnchor, constant: 5).isActive = true
        self.miles_label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.distance_slider.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        self.distance_slider.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        self.distance_slider.topAnchor.constraint(equalTo: self.title_label.bottomAnchor, constant: 60).isActive = true
        self.distance_slider.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    override func getBottomAnchor() -> NSLayoutYAxisAnchor {
        return self.distance_slider.bottomAnchor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(title: String) {
        fatalError("init(title:) has not been implemented")
    }
    
}

fileprivate class AgesView: FilterSectionView {
    
    override var controller: EventFeedFilterController! {
        didSet {
            self.collection_view.delegate = self.controller
            self.collection_view.dataSource = self.controller
        }
    }
    
    var collection_view: UICollectionView!
    
    let ages_array: [AgeRange] = [
        .all,
        .five_plus,
        .thirteen_plus,
        .eighteen_plus,
        .twenty_one_plus
    ]
    
    init() {
        super.init(title: "Ages")
        self.setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        self.collection_view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collection_view.register(AgeCell.self, forCellWithReuseIdentifier: "AgeCell")
        self.collection_view.backgroundColor = .clear
        self.collection_view.translatesAutoresizingMaskIntoConstraints = false
        self.collection_view.allowsMultipleSelection = true
        
        self.addSubview(self.collection_view)
        self.constrainCollectionView()
    }
    
    private func constrainCollectionView() {
        self.collection_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.collection_view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.collection_view.topAnchor.constraint(equalTo: self.title_label.bottomAnchor, constant: 15).isActive = true
        self.collection_view.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func getSelectedAgeRanges() -> [AgeRange] {
        var age_ranges = [AgeRange]()
        if let paths = self.collection_view.indexPathsForSelectedItems {
            for path in paths {
                age_ranges.append(self.ages_array[path.row])
            }
        }
        return age_ranges
    }
    
    override func getBottomAnchor() -> NSLayoutYAxisAnchor {
        return self.collection_view.bottomAnchor
    }
    
    required init(title: String) {
        fatalError("init(title:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate class AgeCell: UICollectionViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    var shows_border = false {
        didSet {
            self.contentView.layer.borderWidth = shows_border ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 100)
        self.contentView.layer.borderColor = UIColor.EVO_blue.cgColor
        
        self.addSubview(label)
        self.label.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate class TagsView: FilterSectionView {
    
    override var controller: EventFeedFilterController! {
        didSet {
            self.table_view.delegate = self.controller
            self.table_view.dataSource = self.controller
        }
    }
    
    var table_view = UITableView(frame: .zero, style: .grouped)
    
    var cells = [UITableViewCell]()
    var labels = [UILabel]()
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
    
    init() {
        super.init(title: "Tags")
        
        self.table_view.translatesAutoresizingMaskIntoConstraints = false
        self.table_view.backgroundColor = .clear
        self.table_view.alwaysBounceVertical = false
        self.table_view.allowsMultipleSelection = true
        self.table_view.isScrollEnabled = false
        self.table_view.tableHeaderView = nil
        self.table_view.tableFooterView = nil
        
        self.addSubview(self.table_view)
        
        self.table_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.table_view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.table_view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.table_view.heightAnchor.constraint(equalToConstant: 490).isActive = true
        
        for i in 0...9 {
            let cell = UITableViewCell()
            
            cell.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 100)
            cell.accessoryType = .checkmark
            
            let label = UILabel(frame: cell.contentView.bounds.insetBy(dx: 15, dy: 0))
            label.text = self.tags_array[i].rawValue
            label.font = UIFont(name: "GothamRounded-Medium", size: 16)
            label.textColor = .white
            
            cell.addSubview(label)
            
            self.cells.append(cell)
            self.labels.append(label)
        }
    }
    
    func getSelectedTags() -> [Tag] {
        var tags = [Tag]()
        if let paths = self.table_view.indexPathsForSelectedRows {
            for path in paths {
                tags.append(self.tags_array[path.row])
            }
        }
        return tags
    }
    
    override func getBottomAnchor() -> NSLayoutYAxisAnchor {
        return self.table_view.bottomAnchor
    }
    
    required init(title: String) {
        fatalError("init(title:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


