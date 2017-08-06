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
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchDisplay.obscuresBackgroundDuringPresentation = false
        self.searchDisplay.searchResultsUpdater = self
        
        
        tableView.tableHeaderView = searchDisplay.searchBar
        
        //Hide the search bar on initial launch
        let offset = CGPoint(x: 0, y: (self.navigationController?.navigationBar.frame.height)!)
        tableView.setContentOffset(offset, animated: true)
        
        //Make the tableView editable from the Navigation Bar
        navigationItem.leftBarButtonItem = self.editButtonItem
        
        //3D Touch Peek & Pop
        if self.traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.view)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            print("Autoselecting row 0")
            let indexZero = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexZero, animated: true, scrollPosition: .none)
            self.performSegue(withIdentifier: "toPassDetail", sender: tableView.cellForRow(at: indexZero))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.leftBarButtonItem?.isEnabled = tableView.visibleCells.count != 0
        tableView.reloadData()
    
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    
    //MARK: - Navigation-related items
    
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.navigationController?.setEditing(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.navigationController?.setEditing(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let revokeAction = UITableViewRowAction(style: .destructive, title: "Revoke") { _, indexPath in
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
        }
        return [revokeAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            C.showDestructiveAlert(withTitle: "Confirm Revocation", andMessage: "Permanently revoke this pass?", andDestructiveAction: "Revoke", inView: self, popoverSetup: nil, withStyle: .alert, forDestruction: { _ in
        
                let pass = C.passes[indexPath.row]
                if C.delete(pass: pass) {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
            
        default: return
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let pdvc = C.storyboard.instantiateViewController(withIdentifier: "passDetailViewController") as! PassDetailViewController
//        
//        pdvc.pass = isSearching() ? filtered[indexPath.row] : C.passes[indexPath.row]
        //        searchDisplay.dismiss(animated: true)
//
//        self.navigationController?.pushViewController(pdvc, animated: true)
    }
    
    
    //Segue preparation for when a UITableViewCell is pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? PassCell, let destination = segue.destination as? PassDetailViewController {
            let index = tableView.indexPathForRow(at: cell.center)!.row
            destination.pass = isSearching() ? filtered[index] : C.passes[index]
        }
        
        searchDisplay.dismiss(animated: true, completion: nil)
        
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
        
        let text = pass.timeStart ?? ""
        let components = text.components(separatedBy: ",")
        
        if components.count >= 3 {
            self.startTime.text = "\(components[0]) at\(components[2])"
        } else {
            self.startTime.text = pass.timeStart ?? "No Start Date & Time"
        }

        fullContactView.setupContactView(forData: pass.image as Data?, andName: pass.name!)
        
    }
}


//MARK: - 3D Touch Peek & Pop Implementation

extension PassesViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let cellPosition = tableView.convert(location, from: self.view)
        guard let indexPath = tableView.indexPathForRow(at: cellPosition) else { return nil }
        
        print("Previewing")
        let rect = self.view.convert(tableView.cellForRow(at: indexPath)!.frame, from: self.tableView)

        previewingContext.sourceRect = rect
        let pdvc = C.storyboard.instantiateViewController(withIdentifier: "passDetailViewController") as! PassDetailViewController
        pdvc.pass = isSearching() ? filtered[indexPath.row] : C.passes[indexPath.row]
        
        return pdvc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        //searchDisplay.dismiss(animated: true)
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}














