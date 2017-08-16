//
//  TruePassesPageViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 6/19/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class TruePassPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var truePassControllers = [UIViewController]()
    var isEmpty = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.view.backgroundColor = UIColor.white
        
        for location in C.nearestTruePassLocations {
            let pvc = C.storyboard.instantiateViewController(withIdentifier: "checkInPassViewController") as! CheckInPassViewController
            pvc.locationForPass = location
            pvc.changedBottomConstraint = 0
            truePassControllers.append(pvc)
        }
        if truePassControllers.isEmpty {
            let pvc = C.storyboard.instantiateViewController(withIdentifier: "checkInPassViewController") as! CheckInPassViewController
            pvc.changedBottomConstraint = 0
            truePassControllers.append(pvc)
            isEmpty = true
        }
                
        self.setViewControllers([truePassControllers.first!], direction: .forward, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if let pageControl = view as? UIPageControl {
                pageControl.backgroundColor = UIColor.white
                pageControl.currentPageIndicatorTintColor = isEmpty ? UIColor.white : UIColor.TrueColors.trueBlue
                pageControl.pageIndicatorTintColor = UIColor.TrueColors.lightestBlueGray
            }
        }
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = truePassControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        //Loop
        guard previousIndex >= 0 else {
            return nil
//            return truePassControllers.last
        }
        guard truePassControllers.count > previousIndex else {
            return nil
        }
        
        return truePassControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = truePassControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let count = truePassControllers.count
        
        //Loop
        guard count != nextIndex else {
            return nil
//            return truePassControllers.first
        }
        guard count > nextIndex else {
            return nil
        }
        
        return truePassControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        let count = C.truePassLocations.count
        return count > 0 ? count : 1
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }


}
