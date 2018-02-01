//
//  TokenView.swift
//  Evo
//
//  Created by Admin on 7/18/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import CLTokenInputView

/* Wrapper class for CLTokenInputView. Creates functioning token views. */
class TokenView: UIView {

    private var height_constraint: NSLayoutConstraint!
    private var height_of_token_input_view: CGFloat = 65
    
    private var data = [String]() // all of the data that the token view can search through
    private var filtered_data = [String]() // buffer containing search resuluts of data
    private var selected_data = [String]() // buffer containing selected data
    private lazy var table_view: UITableView = { // displays search results
        let table_view = UITableView()
        table_view.isHidden = true
        table_view.translatesAutoresizingMaskIntoConstraints = false
        return table_view
    }()

    private let token_input_view: CLTokenInputView = { // token container
        let token_input_view = CLTokenInputView()
        
        token_input_view.backgroundColor = .white
        token_input_view.fieldName = NSLocalizedString("Add: ", comment: "")
        token_input_view.tintColor = .EVO_blue
        token_input_view.drawBottomBorder = true
        token_input_view.layer.borderColor = UIColor.EVO_border_gray.cgColor
        token_input_view.layer.cornerRadius = 5
        token_input_view.layer.masksToBounds = true
        token_input_view.translatesAutoresizingMaskIntoConstraints = false
        
        return token_input_view
    }()
    
    var max_number_of_tokens: UInt?
    
    var is_border_enabled = false {
        didSet {
            self.token_input_view.layer.borderWidth = is_border_enabled ? 1 : 0
        }
    }
    
    // constructor which takes in all of the searchable data and sets up UI
    required init(_ data: [String], field_name: String) {
        self.data = data
        self.token_input_view.fieldName = NSLocalizedString("\(field_name): ", comment: "")
        
        super.init(frame: CGRect.zero)
        
        self.table_view.dataSource = self
        self.table_view.delegate = self
        self.token_input_view.delegate = self
        
        self.table_view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        self.addSubview(token_input_view)
        self.addSubview(table_view)
        
        token_input_view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        token_input_view.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        token_input_view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.height_constraint = self.heightAnchor.constraint(equalToConstant: height_of_token_input_view)
        self.height_constraint.isActive = true
        
        constrainTableView()
    }
    
    func constrainTableView() {
        table_view.topAnchor.constraint(equalTo: self.token_input_view.bottomAnchor).isActive = true
        table_view.centerXAnchor.constraint(equalTo: self.token_input_view.centerXAnchor).isActive = true
        table_view.widthAnchor.constraint(equalTo: self.token_input_view.widthAnchor).isActive = true
        table_view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func getAllTokens() -> [CLToken] {
        return self.token_input_view.allTokens
    }
    
    func getBottomAnchorOfInputView() -> NSLayoutYAxisAnchor {
        return self.token_input_view.bottomAnchor
    }
    
    func changeHeightConstraint(withConstant height: CGFloat) {
        self.height_constraint.isActive = false
        self.height_constraint.constant = height
        self.height_constraint.isActive = true
    }
    
    private func openTableView() {
        self.table_view.isHidden = false
        self.changeHeightConstraint(withConstant: 200)
    }
    
    private func closeTableView() {
        self.table_view.isHidden = true
        self.changeHeightConstraint(withConstant: height_of_token_input_view)
    }
    
}

/* TokenView extensions */

extension TokenView: CLTokenInputViewDelegate {
    
    // handle a change of text in the input view
    func tokenInputView(_ view: CLTokenInputView, didChangeText text: String?) {
        
        if let max = self.max_number_of_tokens {
            if self.selected_data.count >= Int(max) {
                // if a maximum token amount is defined and reached then return
                self.closeTableView()
                return
            }
        }
        
        if text!.isEmpty {
            // if entered text is empty then clear buffer
            self.filtered_data = []
            self.closeTableView()
        }
        else {
            // search for entered text and update the filtered data buffer
            let predicate = NSPredicate(format: "self contains[cd] %@", text ?? "")
            self.filtered_data = self.data.filter { predicate.evaluate(with: $0) }
            self.openTableView()
        }
        self.table_view.reloadData()
    }
    
    // if a token is added then add the token's text to the selected data buffer
    func tokenInputView(_ view: CLTokenInputView, didAdd token: CLToken) {
        self.selected_data.append(token.displayText)
    }
    
    // if a token is removed then remove its text from the selected data buffer
    func tokenInputView(_ view: CLTokenInputView, didRemove token: CLToken) {
        let idx = self.selected_data.index(of: token.displayText)
        self.selected_data.remove(at: idx!)
    }
    
    func tokenInputView(_ view: CLTokenInputView, tokenForText text: String) -> CLToken? {
        guard self.filtered_data.count > 0 else { return nil }
        
        var matching_name: String!
        
        for name in filtered_data {
            if !selected_data.contains(name) {
                matching_name = name
                break
            }
        }
        
        guard let _ = matching_name else { return nil }
        
        let match = CLToken()
        match.displayText = matching_name
        match.context = nil
        return match
    }
    
    func tokenInputViewDidEndEditing(_ view: CLTokenInputView) {
        view.accessoryView = nil
    }
    
    func tokenInputViewDidBeginEditing(_ view: CLTokenInputView) {
        self.layoutIfNeeded()
    }
    
    func tokenInputView(_ view: CLTokenInputView, didChangeHeightTo height: CGFloat) {
        self.height_of_token_input_view = height + 10
        self.changeHeightConstraint(withConstant: self.height_of_token_input_view)
    }
    
}

extension TokenView: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filtered_data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        let name = self.filtered_data[indexPath.row]
        cell.textLabel!.text = name
        
        cell.accessoryType = self.selected_data.contains(name) ? .checkmark : .none
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = self.filtered_data[indexPath.row]
        
        guard !self.selected_data.contains(name) else { return }
        
        let token = CLToken()
        token.displayText = name
        token.context = nil
        self.token_input_view.add(token)
    }
    
}
