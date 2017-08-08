//
//  TruePassInfoViewControllers.swift
//  True Pass
//
//  Created by Cliff Panos on 8/7/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class AboutTruePassTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.estimatedRowHeight = 500
        //tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            let developerVC = C.storyboard.instantiateViewController(withIdentifier: "developmentViewController")
            self.navigationController!.pushViewController(developerVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    @IBAction func visitTruePassWebsite(_ sender: Any) {
        UIApplication.shared.open(URL(string: "http://www.truepass.org")!)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

}

class TruePassDevelopmentTableViewController: UITableViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlRequest = URLRequest(url: URL(string: "https://www.github.com/cliffpanos/True-Pass-iOS")!)
        webView.loadRequest(urlRequest)
    }
    
    @IBAction func done(_ sender: Any) {
        if let nav = self.navigationController {
            nav.dismiss(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
}
