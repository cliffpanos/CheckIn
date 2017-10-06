//
//  SplitViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 6/19/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    weak static var instance: SplitViewController?
    
    static var isShowingPrimary: Bool {
        guard let instance = instance else { return false }
        for vc in instance.viewControllers { if vc is PassesViewController { return true } }
        return false
    }
    static var isShowingDetail: Bool {
        guard let instance = instance else { return false }
        for vc in instance.viewControllers { if vc is PassDetailNavigationController { return true } }
        return false
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        SplitViewController.instance = self
        self.delegate = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        print("primary for collapsing \(viewControllers[0])")
        return viewControllers[0]
    }
    
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        //print("hide? \(vc)")
        if vc is PassesNavigationController || vc is PassDetailNavigationController { return false }
        print("hiding")
        return true
    }
//    func splitViewController(_ splitViewController: UISplitViewController,
//                             collapseSecondary secondaryViewController: UIViewController,
//                             onto primaryViewController: UIViewController) -> Bool{
//        print("collapse second?")
//        guard let secondaryAsNavController = secondaryViewController as? PassDetailNavigationController else { return false }
//        guard let topAsDetailController = secondaryAsNavController.topViewController as? PassDetailEmbedderController else { print("didnt find embedder"); return false }
//        if topAsDetailController.pass == nil {
//            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//            print("discarding second VC")
//            return true
//        }
//        print("made it to end")
//        return false
//    }

    
    deinit {
        SplitViewController.instance = nil
    }
            

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
