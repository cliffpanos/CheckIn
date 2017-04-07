//
//  PassesViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PassesViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let offset = CGPoint(x: 0, y: (self.navigationController?.navigationBar.frame.height)!)
        tableView.setContentOffset(offset, animated: true)
        
        //Setup ToolBar associated with keyboard
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissKeyboard))
        toolbar.items = [flex, done]
        toolbar.sizeToFit()
        searchBar.inputAccessoryView = toolbar
        
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
    
    
}


//MARK: - TableView Delegation and Prototype Cell Implementation -----------------------------

extension PassesViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "passCell", for: indexPath) as! PassCell

        let pass = C.passes[indexPath.row]
        cell.decorate(for: pass)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return C.passes.count
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //TODO
        return false
    }
    
    //Segue preparation for when a TableViewCell is pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? UITableViewCell, let destination = segue.destination as? PassDetailViewController {
            destination.pass = C.passes[tableView.indexPath(for: cell)!.row]
        }
        
    }
    
}

class PassCell: UITableViewCell {
    
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var contactView: UIImageView!
    @IBOutlet weak var emailTitle: UILabel!
    
    func decorate(for pass: Pass) {
        self.nameTitle.text = pass.name ?? "Contact Name"
        self.emailTitle.text = pass.email ?? ""
        
        if let imageData = pass.image {
            let image = UIImage(data: imageData as Data)
            //image = image?.resize(image!, toFrame: contactView.frame)
            contactView.image = image
            return
        }
        
        let imageName = C.passesActive ? "greenContactIcon" : "contactIcon"
        contactView.image = UIImage(named: imageName)
    }
}


//MARK: - UIImage class extension --------------------------------------------

extension UIImage {
    
    func resize(_ image: UIImage, toFrame newFrame: CGRect) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newFrame.size, false, scale)
        image.draw(in: newFrame)
        
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: newFrame) else { return image }
        //UIBezierPath(ovalIn: newFrame).addClip()
        //UIImage(cgImage: cgImage).draw(in: newFrame)
        return UIGraphicsGetImageFromCurrentImageContext()!
        
    }

}
