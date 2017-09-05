//
//  LocationManager.swift
//  True Pass
//
//  Created by Cliff Panos on 8/13/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit
import FirebaseDatabase

class LocationManager {
    
    static var sharedLocationManager = CLLocationManager()
    
    static var userLocation: CLLocation? {
        return sharedLocationManager.location
    }
    
    static var nearestLocation: TPLocation? {
        if C.truePassLocations.isEmpty { return nil }
        
        return C.nearestTruePassLocations[0]
    }
    
    static var coreDataLocations: [TPLocation] {
        let context = C.appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TPLocation> = TPLocation.fetchRequest()
        if let locations = try? context.fetch(fetchRequest) {
            print("*** \(locations.count) TPLocations fetched from CoreData")
            return locations
        }
        return [TPLocation]()
    }
    
    
    ///Database function
//    static func createNewLocation(title: String, shortTitle: String, locationType: TPLocationType, coordinate: CLLocationCoordinate2D, geofenceRadius: CLLocationDistance, openTime: String?, closeTime: String?, accessCode: String) -> String {
//        
    static func createNewLocation(_ location: TPLocation) {
        
        let locationService = FirebaseService(entity: .TPLocation)
        let identifier = locationService.identifierKey
        location.identifier = identifier
        locationService.enterData(forIdentifier: identifier, data: location)
        
        let locationListService = FirebaseService(entity: .TPLocationList)
        locationListService.addChildData(forIdentifier: identifier, key: Accounts.userIdentifier, value: true) //Because the current user is by default an admin
        
        addUser(Accounts.userIdentifier, toAdminListAtLocation: identifier)
        affiliate(userIdentifier: Accounts.userIdentifier, with: location, using: defaultAffiliation)
        addTitleKeywords(forLocation: location)
        addTileChunk(forLocation: location)
        
        let userListService = FirebaseService(entity: .TPUserList)
        userListService.addChildData(forIdentifier: Accounts.userIdentifier, key: identifier, value: true) //Because the current user is by default an admin
        
    }
    
    
    //--------- helper functions -------------
    
    
    static var defaultAffiliation: TPAffiliation {
        let affiliation = TPAffiliation(.TPAffiliation)
        affiliation.accessCodeQR = "\(Date().addingTimeInterval(TimeInterval(arc4random())).timeIntervalSince1970)"
        return affiliation
    }
    
    static func affiliate(userIdentifier: String, with location: TPLocation, using affiliation: TPAffiliation) {
        affiliation.uid = userIdentifier
        let affiliationService = FirebaseService(entity: .TPAffiliation)
        affiliationService.addChildData(forIdentifier: userIdentifier, key: location.identifier!, value: affiliation.dictionaryForm)
        //affiliationService.reference.child(userIdentifier).child(location.identifier!).setValue(affiliation.dictionaryForm)
    }
    
    static func addUser(_ userIdentifier: String, toAdminListAtLocation locationIdentifier: String) {
        let locationListService = FirebaseService(entity: .TPLocationList)
        locationListService.reference.child(locationIdentifier).child("TPAdminList").child(userIdentifier).setValue(true)
    }
    
    static func addTitleKeywords(forLocation location: TPLocation) {
        let title = location.title!
        let nonAlphanumerics = CharacterSet.alphanumerics.inverted
        let stripped = title.components(separatedBy: nonAlphanumerics).joined(separator: " ")
        let separated = stripped.components(separatedBy: " ")
        
        var resultingKeywords = [String]()
        for word in separated {
            if !C.stopNonKeywords.contains(word.lowercased()) && Int(word) == nil && !word.isEmptyOrWhitespace() {
                resultingKeywords.append(word.lowercased())
            }
        }
        print("Keywords to add to Firebase: \(resultingKeywords)")
        
        let keywordService = FirebaseService(entity: .TPLocationKeywordList)
        for keyword in resultingKeywords {
            keywordService.reference.child(keyword).child(location.identifier!).setValue(location.type.rawValue)
        }
    }
    
    static func addTileChunk(forLocation location: TPLocation) {
        let tileService = FirebaseService(entity: .TPLocationTileList)
        let lat = location.latitude.formattedToHundredths
        let long = location.longitude.formattedToHundredths
        let tileChunk: String = "\(lat)T\(long)"
        tileService.addChildData(forIdentifier: tileChunk, key: location.identifier!, value: location.title!)
    }
    
    
    
    //---------- Map functions
    
    
    static func chooseMapType(for mapView: MKMapView, from button: UIButton, arrow direction: UIPopoverArrowDirection, in viewController: UIViewController) {
        func changeTo(mapType: MKMapType) {
            mapView.mapType = mapType
        }
        let alert = UIAlertController(title: "Show", message: nil, preferredStyle: .actionSheet)
        let standard = UIAlertAction(title: "Map", style: .default) {_ in changeTo(mapType: .standard)}
        let satellite = UIAlertAction(title: "Satellite", style: .default) {_ in changeTo(mapType: .satellite)}
        let hybrid = UIAlertAction(title: "Hybrid", style: .default) {_ in changeTo(mapType: .hybrid)}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in alert.dismiss(animated: true) })
        alert.addAction(standard); alert.addAction(satellite); alert.addAction(hybrid); alert.addAction(cancel)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = button
            popover.sourceRect = button.bounds
            popover.permittedArrowDirections = [direction]
        }
        viewController.present(alert, animated: true)
    }
    
    static func zoomClose(to location: CLLocationCoordinate2D, in mapView: MKMapView) {
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(newRegion, animated: true)
    }
    
    static func zoom(to location: CLLocationCoordinate2D, in mapView: MKMapView, sizeDelta: Double = 0.05) {
        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: sizeDelta, longitudeDelta: sizeDelta))
        mapView.setRegion(newRegion, animated: true)
    }
    
    static func zoomToUserLocation(in mapView: MKMapView) {
        guard let location = userLocation else { return }
        let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(newRegion, animated: true)
    }
    
    
}



//MARK: - Utility functions
extension LocationManager {
    
    static func address(for location: CLLocation, completion: @escaping (_ address: [String: Any]?, _ error: Error?) -> ()) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            
            if let error = error {
                completion(nil, error)
            } else {
                
                let placeMark = placemarks?[0]
                
                guard var address = placeMark?.addressDictionary  as? [String: Any] else {
                    return
                }
                address["InlandWater"] = placeMark?.inlandWater
                address["Ocean"] = placeMark?.ocean
                
                completion(address, nil)
                
            }
            
        }
    }
}
