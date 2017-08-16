//
//  PinSelectionViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 8/14/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit

class PinSelectionViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var useThisLocationButton: UIBarButtonItem!
    
    var location: TPLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let location = location {
            mapView.addAnnotation(location)
            LocationManager.zoomClose(to: location.coordinate, in: mapView)
            self.navigationItem.title = ""
            setTitle(for: location)
        } else {
            LocationManager.zoomToUserLocation(in: mapView)
        }
        useThisLocationButton.isEnabled = location != nil
    }
    
    @IBAction func chooseMapType(_ sender: UIButton) {
        LocationManager.chooseMapType(for: mapView, from: sender, arrow: .right, in: self)
    }
    @IBAction func zoomToUserLocation(_ sender: UIButton) {
        LocationManager.zoomToUserLocation(in: mapView)
    }
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        self.showSimpleAlert("Press and hold a location on the map to select it.", message: nil)
    }
    
    @IBAction func useThisLocation(_ sender: Any) {
        let newLocationVC = self.navigationController!.viewControllers.first! as! NewLocationTableViewController
        newLocationVC.location = self.location
        self.navigationController!.popViewController(animated: true)
    }
    
    var currentlyRecognizing = false
    @IBAction func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.recognized {
            currentlyRecognizing = false
        }
        guard gestureRecognizer.state == UIGestureRecognizerState.began && !currentlyRecognizing else {
            return
        }
        currentlyRecognizing = true
    
        let gestureLocation = gestureRecognizer.location(in: mapView)
        let gestureCoordinate = mapView.convert(gestureLocation, toCoordinateFrom: mapView)
        
        let pin = self.location ?? TPLocation()
        pin.title = "New Location"
        pin.coordinate = gestureCoordinate
        
        if let current = mapView.annotations.first {
            if current is MKUserLocation {
                if mapView.annotations.count > 1 {
                    let toRemove = mapView.annotations[1]
                    mapView.removeAnnotation(toRemove)
                }
            } else {
                mapView.removeAnnotation(current)
            }
        }
        mapView.addAnnotation(pin)
        setTitle(for: pin)
        self.location = pin
        useThisLocationButton.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AV")
        view.animatesDrop = true
        view.pinTintColor = UIColor.TrueColors.softRed
        view.isDraggable = true
        view.canShowCallout = true
        let imageView = UIImageView(image: #imageLiteral(resourceName: "truePassLaunch"))
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.leftCalloutAccessoryView = imageView
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending, let coordinate = view.annotation?.coordinate {
            location?.coordinate = coordinate
        }
        if let annotation = view.annotation {
            setTitle(for: annotation)
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        self.showSimpleAlert("Failed to load Map", message: nil)
    }
    
    func setTitle(for annotation: MKAnnotation) {
        LocationManager.address(for: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), completion: { address, error in
            if let _ = error {
                self.navigationItem.title = ""
                return
            }
            if let city = address?["City"] as? String {
                self.navigationItem.title = city
                if let state = address?["State"] as? String {
                    self.navigationItem.title! += ", \(state)"
                }
            }
            if let inlandWater = address?["InlandWater"] as? String {
                self.showSimpleAlert("Location in Water?", message: "It appears that this location may be located in \"\(inlandWater)\"...")
            }
            if let ocean = address?["Ocean"] as? String {
                self.showSimpleAlert("Location in the Ocean???", message: "It appears that this location may be located in the \"\(ocean)\"...")
            }
        })
    }

    

}
