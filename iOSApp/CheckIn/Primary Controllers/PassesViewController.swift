//
//  PassesViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PassesNavigationController: UINavigationController { }

class PassesViewController: ManagedViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var searchDisplay = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar!
    var filtered = [TPPass]()
    var selectedIndexPath: IndexPath?
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if C.passes.count == 0 { switchToGuestGettingStarted() }

        self.navigationItem.leftBarButtonItem?.isEnabled = tableView.visibleCells.count != 0
        tableView.reloadData()
        
        //TODO FIX THIS
        if !(SplitViewController.instance?.isCollapsed ?? true) && selectedIndexPath == nil {
            print("Autoselecting row 0")
            let indexZero = IndexPath(row: 0, section: 0)
            self.selectedIndexPath = indexZero
            tableView.selectRow(at: indexZero, animated: true, scrollPosition: .none)
            self.performSegue(withIdentifier: "toPassDetail", sender: tableView.cellForRow(at: indexZero))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let indexPath = selectedIndexPath else { return }
        if SplitViewController.isShowingDetail { tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle) }
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
        filtered = C.passes.filter { ($0.name).lowercased().contains(text) }
        
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
        return false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSearching()
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
        print("\(indexPath.row)")
        switch editingStyle {
        case .delete:
            showDestructiveAlert("Confirm Revocation", message: "Permanently revoke this pass?", destructiveTitle: "Revoke", popoverSetup: nil, withStyle: .alert, forDestruction: { _ in
                let row = indexPath.row; let section = indexPath.section
                let relevantPasses = self.isSearching() ? self.filtered : C.passes
                let pass = relevantPasses[row]
                let sameCellSelectedAsPresented = indexPath == self.selectedIndexPath
                if PassManager.delete(pass: pass) {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    return
                }
                guard (row - 1 < relevantPasses.count - 1 && row - 1 >= 0)
                    || (row < relevantPasses.count - 1 && row >= 0) else {
                        self.switchToGuestGettingStarted()
                        return
                }
                guard sameCellSelectedAsPresented else { print(1); return }
                guard SplitViewController.isShowingDetail else { print(2); return }
                let newIndexPath = IndexPath(row: (row - 1 < relevantPasses.count - 1 && row - 1 >= 0) ? row - 1 : row, section: section)
                tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
                let cell = tableView.cellForRow(at: newIndexPath)
                self.performSegue(withIdentifier: "toPassDetail", sender: cell)
                
            })
            
        default: return
        }
        
    }
    
    
    func switchToGuestGettingStarted() {
        (self.navigationController!.tabBarController! as! RootViewController).switchToGuestRootController(withIdentifier: "passInfoViewController")
    }
    
    
    //Segue preparation for when a UITableViewCell is pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? PassCell{
            let embedder = (segue.destination as! UINavigationController).viewControllers.first! as! PassDetailEmbedderController
            let indexPath = tableView.indexPathForRow(at: cell.center)!
            self.selectedIndexPath = indexPath
            embedder.pass = isSearching() ? filtered[indexPath.row] : C.passes[indexPath.row]
        }
        
        searchDisplay.dismiss(animated: true, completion: nil)
        
    }
    
}

class PassCell: UITableViewCell {
    
    var pass: TPPass!
    var contactTextView = ContactView()

    
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var fullContactView: ContactView!
    
    func decorate(for pass: TPPass) {
        
        self.pass = pass
        
        self.nameTitle.text = pass.name 
        
        guard let start = pass.startDate else {
            self.startTime.text = "No Start Date & Time"
            return }
        let text = C.format(date: start as Date)
        let components = text.components(separatedBy: ",")
        
        if components.count >= 3 {
            self.startTime.text = "\(components[0]) at\(components[2])"
        } else {
            self.startTime.text = C.format(date: start as Date)
        }
        
        FirebaseStorage.shared.retrieveImageData(for: pass.identifier!, entity: .TPPass) { data, _ in
                self.fullContactView.setupContactView(forData: data, andName: pass.name)
                if let data = data {
                    pass.imageData = data as NSData
                }
            }
        

    //fullContactView.setupContactView(forData: pass.imageData as Data?, andName: pass.name)
        
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = selected ? UIColor.groupTableViewBackground : UIColor.white
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = highlighted ? UIColor.groupTableViewBackground : UIColor.white
    }
}


//MARK: - 3D Touch Peek & Pop Implementation

extension PassesViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let cellPosition = tableView.convert(location, from: self.view)
        guard let indexPath = tableView.indexPathForRow(at: cellPosition) else { return nil }
        
        let rect = self.view.convert(tableView.cellForRow(at: indexPath)!.frame, from: self.tableView)

        previewingContext.sourceRect = rect
        let pdvc = C.storyboard.instantiateViewController(withIdentifier: "passDetailNavigationController") as! PassDetailNavigationController
        (pdvc.viewControllers.first! as! PassDetailEmbedderController).pass = isSearching() ? filtered[indexPath.row] : C.passes[indexPath.row]
        
        return pdvc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        //searchDisplay.dismiss(animated: true)
        SplitViewController.instance?.showDetailViewController(viewControllerToCommit, sender: nil)
        //self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}














