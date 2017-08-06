//
//  CDTableViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 6/20/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit


enum CDTableViewLayoutType {
    case fixed(Int)
    case percentage(Double, Int) //Percentage of portrait and then minimum for landscape
    case calculated(() -> Int)
    
}

enum CDOrientationType {
    case portrait
    case landscape
}

class CDTableViewController: UITableViewController {

    var autoDetectControllerBars: Bool = true
    var tableViewHeightSpace: CGFloat {
        return CGFloat(orientation == .portrait ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width)
    }
    var orientation: CDOrientationType {
        return UIDevice.current.orientation.isPortrait || (UIDevice.current.orientation.isFlat && UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width) ? .portrait : .landscape
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let layout = self.tableView(self.tableView, heightLayoutForIndexPath: indexPath)
        
        //TODO this is in progress and must be modified so that percentage heights are calculated at the very end
        
        switch layout {
        case let .calculated(heightCalculator):
            return CGFloat(heightCalculator())
        
        case let .fixed(fixedHeight):
            return CGFloat(fixedHeight)
            
        case let .percentage(percentage, minimumHeight):
            let proportionalHeight = tableViewHeightSpace * CGFloat(percentage)
            let maximumHeight = max(minimumHeight, Int(proportionalHeight))
            return CGFloat(maximumHeight)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightLayoutForIndexPath indexPath: IndexPath) -> CDTableViewLayoutType {
        
        let defaultHeight = Int(self.tableView.rowHeight)
        
        return CDTableViewLayoutType.fixed(defaultHeight)
    }

    
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        
//        let cornerRadius: CGFloat = 12
//        cell.backgroundColor = .clear
//        
//        let layer = CAShapeLayer()
//        let pathRef = CGMutablePath()
//        let bounds = cell.bounds.insetBy(dx: 0, dy: 0)
//        var addLine = false
//        
//        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//            pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
//        } else if indexPath.row == 0 {
//            pathRef.move(to: .init(x: bounds.minX, y: bounds.maxY))
//            pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.minY), tangent2End: .init(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
//            pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.minY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
//            pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
//            addLine = true
//        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//            pathRef.move(to: .init(x: bounds.minX, y: bounds.minY))
//            pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.maxY), tangent2End: .init(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
//            pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.maxY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
//            pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
//        } else {
//            pathRef.addRect(bounds)
//            addLine = true
//        }
//        
//        layer.path = pathRef
//        layer.fillColor = UIColor(white: 1, alpha: 0.8).cgColor
//        
//        if (addLine == true) {
//            let lineLayer = CALayer()
//            let lineHeight = 1.0 / UIScreen.main.scale
//            lineLayer.frame = CGRect(x: bounds.minX + 10, y: bounds.size.height - lineHeight, width: bounds.size.width - 10, height: lineHeight)
//            lineLayer.backgroundColor = tableView.separatorColor?.cgColor
//            layer.addSublayer(lineLayer)
//        }
//        
//        let testView = UIView(frame: bounds)
//        testView.layer.insertSublayer(layer, at: 0)
//        testView.backgroundColor = .clear
//        cell.backgroundView = testView
//    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
