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
    
    var passes = [Pass]()
    
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.passes = C.passes
        tableView.reloadData()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {

        C.showDestructiveAlert(withTitle: "Logout", andMessage: "Are you sure you want to logout?", andDestructiveAction: "Logout", inView: self) { action in
            //if C.result {
                C.userIsLoggedIn = false
                let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
                self.present(controller, animated: true, completion: nil)
            //}
        }
    }
    
    @IBAction func newPassPressed(_ sender: Any) {
        let controller = C.storyboard.instantiateViewController(withIdentifier: "newPassViewController")
        self.tabBarController?.present(controller, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
}

extension PassesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pass = C.passes[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "passDetailViewController") as! PassDetailViewController
        controller.pass = pass
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "passCell", for: indexPath) as! PassCell

        let pass = C.passes[indexPath.row]
        cell.decorate(for: pass)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return C.passes.count
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
            var image = UIImage(data: imageData as Data)
            image = image?.resize(image!, toFrame: contactView.frame)
            contactView.image = image
            return
        }
        
        let imageName = C.passesActive ? "greenContactIcon" : "contactIcon"
        contactView.image = UIImage(named: imageName)
    }
}

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
