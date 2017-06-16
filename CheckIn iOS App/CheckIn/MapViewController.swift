//
//  MapViewController.swift
//  True Pass
//
//  Created by Cliff Panos on 4/2/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeController: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    var locationCollectionViewSpace: CGFloat {
        debugPrint("Screen: \(UIScreen.main.bounds)")
        print("Vertical? \(UIDevice.current.isVertical)")
        return CGFloat(UIDevice.current.isVertical ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width) * 0.28
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(considerOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        
        for location in C.truePassLocations {
            mapView.addAnnotation(location)
            let circle = MKCircle(center: location.coordinate, radius: 0.05 as CLLocationDistance)
            self.mapView.add(circle)
        }
        
        zoomToCheckInLocation()
        //https://www.raywenderlich.com/136165/core-location-geofencing-tutorial

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        considerOrientation()
    }
    
    func considerOrientation() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        self.mapView.isScrollEnabled = UIDevice.current.isVertical
    }
    
    
    @IBAction func mapTypeSelected(_ sender: Any) {
        let mapTypes: [MKMapType] = [.standard, .satellite, .hybrid]
        mapView.mapType = mapTypes[mapTypeController.selectedSegmentIndex]
    }
    
    @IBAction func zoomButtonPressed(_ sender: Any) {
        zoomToUserLocation()
    }
    
    func zoomToCheckInLocation() {
        if C.truePassLocations.count > 0 {
            let truePassLocation = C.truePassLocations[0].coordinate
            zoom(to: truePassLocation, withViewSize: 0.005)
        }
    }
    
    func zoomToUserLocation() {
        zoom(to: mapView.userLocation.coordinate, withViewSize: 0.05)
    }
    
    func zoom(to location: CLLocationCoordinate2D, withViewSize sizeDelta: CLLocationDegrees) {
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: sizeDelta, longitudeDelta: sizeDelta))
        mapView.setRegion(newRegion, animated: true)
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.white
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    

}


//MARK: - Handle TableViewController Delegation
extension MapViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let heightSpace = UIScreen.main.bounds.size.height - 95 - 49
        let locationSpace = locationCollectionViewSpace 
        
        if !UIApplication.shared.isStatusBarHidden && UIDevice.current.userInterfaceIdiom != .pad {
            //heightSpace -= 20
        }
        
        let scaledHeights: (forVertical: CGFloat, forHorizontal: CGFloat)
        switch (indexPath.row) {
        case 0 : scaledHeights = (95, 80)
        case 1: scaledHeights = (heightSpace - locationSpace, heightSpace)
        case 2: scaledHeights = (locationSpace, locationSpace)
        case 3: scaledHeights = (44.5, 44.5)
        default: scaledHeights = (200, 100)
        }
        return UIDevice.current.isVertical ? scaledHeights.forVertical : scaledHeights.forHorizontal
    }
    
    
    
    
}




extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return C.truePassLocations.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell
        switch (indexPath.row) {
        case 0 :
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "truePassCell", for: indexPath) as! LocationCell
        case 1..<C.truePassLocations.count + 1 :
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath)
            (cell as! LocationCell).decorate(for: C.truePassLocations[indexPath.row - 1])
        default :
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addLocationCell", for: indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionSize = collectionView.frame.size
        let cellHeight = collectionSize.height
        let cellWidth = cellHeight - 32.5
        
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }

}


@IBDesignable
class LocationCell: UICollectionViewCell {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationTypeLabel: UILabel!

    var location: TPLocation!
    func decorate(for location: TPLocation) {
        
        self.location = location
        
        locationTypeLabel.text = (location.locationType ?? "Location").localizedUppercase
        titleLabel.text = location.shortTitle
        
        let typeDetails = TPLocationType.Details[location.type]!
        locationIcon.image = UIImage(named: typeDetails.iconName)
        gradientView.topColor = typeDetails.colorA
        gradientView.bottomColor = typeDetails.colorB
        
        
    }
    
}








