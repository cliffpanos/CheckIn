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
    var isVertical: Bool {
        return tableView.frame.height > tableView.frame.width
    }
    
    let locationManager = GeoLocationManager.sharedLocationManager
    var locationCollectionViewSpace: CGFloat {
        let space = CGFloat(isVertical ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width) * 0.28
        return space
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
            let circle = MKCircle(center: location.coordinate, radius: 0.01 as CLLocationDistance)
            self.mapView.add(circle)
        }
        
        zoomToCheckInLocation()
        //https://www.raywenderlich.com/136165/core-location-geofencing-tutorial

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        considerOrientation()
//        tableView.endUpdates()
    }
    
    func considerOrientation() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        self.mapView.isScrollEnabled = isVertical
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
    }
    
    
    @IBAction func mapTypeSelected(_ sender: Any) {
        let mapTypes: [MKMapType] = [.standard, .satellite, .hybrid]
        mapView.mapType = mapTypes[mapTypeController.selectedSegmentIndex]
    }
    
    @IBOutlet weak var zoomToUserLocationButton: CDButton!
    @IBAction func zoomButtonPressed(_ sender: Any) {
        zoomToUserLocation()
    }
    
    func zoomToCheckInLocation() {
        if C.truePassLocations.count > 0 {
            let truePassLocation = C.truePassLocations[0].coordinate
            zoom(to: truePassLocation, withViewSize: 0.05)
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
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("Located")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("started")
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("LOCATION UPDATED")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.white
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        zoomToUserLocationButton.tintColor = mapView.isUserLocationVisible ? UIColor.TrueColors.lightBlue : UIColor.TrueColors.trueBlue
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocationDetailEmbedder", let cell = sender as? LocationCell {
            let detailVC = segue.destination as! LocationDetailEmbedderController
            detailVC.location = cell.location
        }
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
        case 0 :
            scaledHeights = UIApplication.shared.isStatusBarHidden ? (95, 80) : (95, 95)
        case 1: scaledHeights = (heightSpace - locationSpace, heightSpace)
        case 2: scaledHeights = (locationSpace, locationSpace)
        case 3: scaledHeights = (44.5, 44.5)
        default: scaledHeights = (200, 100)
        }
        return isVertical ? scaledHeights.forVertical : scaledHeights.forHorizontal
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
        
        let totalItems = collectionView.numberOfItems(inSection: 0)
        let collectionSize = collectionView.frame.size
        let cellHeight = collectionSize.height
        var cellWidth = cellHeight - 32.5
        
        //At the beginning and end of the collectionView, we need extra 16px padding
        if indexPath.row == 0 || indexPath.row == totalItems - 1 {
            cellWidth += 16;
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }

}


@IBDesignable
class LocationCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var location: TPLocation!
    func decorate(for location: TPLocation) {
        
        self.location = location
        
        locationTypeLabel.text = (location.locationType ?? "Location").localizedUppercase
        titleLabel.text = location.shortTitle
        
        let typeDetails = TPLocationType.Details[location.type]!
        locationIcon.image = UIImage(named: typeDetails.iconName)
        backgroundImage.image = UIImage(named: "\(typeDetails.iconName)Scene")
        
    }
    
}








