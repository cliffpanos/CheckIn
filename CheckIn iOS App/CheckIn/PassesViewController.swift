//
//  PassesViewController.swift
//  CheckIn
//
//  Created by Cliff Panos on 4/1/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PassesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var passes = [Pass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let offset = CGPoint(x: 0, y: (self.navigationController?.navigationBar.frame.height)!)
        tableView.setContentOffset(offset, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        self.passes = C.passes
        tableView.reloadData()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        print("Logging out!!")
        C.userIsLoggedIn = false
        let controller = C.storyboard.instantiateViewController(withIdentifier: "loginViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func newPassPressed(_ sender: Any) {
        let controller = C.storyboard.instantiateViewController(withIdentifier: "newPassViewController")
        self.tabBarController?.present(controller, animated: true, completion: nil)
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
        self.nameTitle.text = pass.name ?? ""
        
        let imageName = C.passesActive ? "greenContactIcon" : "contactIcon"
        contactView.image = UIImage(named: imageName)
    }
}
