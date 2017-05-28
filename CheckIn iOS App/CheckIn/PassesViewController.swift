//
//  PassesViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PassesViewController: ManagedViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var searchDisplay = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar!
    var filtered = [Pass]()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = searchDisplay.searchBar
        searchBar.placeholder = "Search guest passes"
        searchBar.autocapitalizationType = .words
        searchBar.delegate = self
        searchDisplay.dimsBackgroundDuringPresentation = false
        self.searchDisplay.searchResultsUpdater = self
        
        
        tableView.tableHeaderView = searchDisplay.searchBar
        
        //Hide the search bar on initial launch
        let offset = CGPoint(x: 0, y: (self.navigationController?.navigationBar.frame.height)!)
        tableView.setContentOffset(offset, animated: true)
        
        /*Setup ToolBar associated with keyboard
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissKeyboard))
        toolbar.items = [flex, done]
        toolbar.sizeToFit()
        searchBar.inputAccessoryView = toolbar*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    
    }
    
    
    
    //MARK: - Navigation-related items
    
    @IBAction func newPassPressed(_ sender: Any) {
        let controller = C.storyboard.instantiateViewController(withIdentifier: "newPassViewController")
        self.tabBarController?.present(controller, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    
    //MARK: - Handle search bar and search controller
    fileprivate func isSearching() -> Bool {
        return searchDisplay.isActive && !(searchDisplay.searchBar.text ?? "").isEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let text = searchBar.text?.lowercased() ?? ""
        filtered = C.passes.filter { ($0.name ?? "").lowercased().contains(text) }
        
        print("FILTERING FROM FUNCTION CALLED!!")
        tableView.reloadData()
    
    }
    
}


//MARK: - TableView Delegation and Prototype Cell Implementation -----------------------------

extension PassesViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "passCell", for: indexPath) as! PassCell

        let pass = isSearching() ? filtered[indexPath.row] : C.passes[indexPath.row]
        cell.decorate(for: pass)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching() ? filtered.count : C.passes.count
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //TODO
        return false
    }
    
    
    //Segue preparation for when a TableViewCell is pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? PassCell, let destination = segue.destination as? PassDetailViewController {
            let index = tableView.indexPathForRow(at: cell.center)!.row
            destination.pass = isSearching() ? filtered[index] : C.passes[index]
        }
        
        searchDisplay.dismiss(animated: true, completion: nil)
        searchBar.text = ""

        
    }
    
}

class PassCell: UITableViewCell {
    
    var pass: Pass!
    var contactTextView = ContactView()

    
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var fullContactView: ContactView!
    
    func decorate(for pass: Pass) {
        
        self.pass = pass
        
        self.nameTitle.text = pass.name ?? "Contact Name Unknown"
        
        if let text = pass.timeStart {
            let components = text.components(separatedBy: ",")
            self.startTime.text = "\(components[0]) at\(components[2])"
        } else {
            self.startTime.text = pass.timeStart ?? "No Start Date & Time"
        }

        fullContactView.setupContactView(forData: pass.image as Data?, andName: pass.name!)
        
    }
}
