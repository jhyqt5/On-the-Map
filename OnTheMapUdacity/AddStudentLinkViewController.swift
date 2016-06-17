//
//  AddStudentLinkViewController.swift
//  OnTheMapUdacity
//
//  Created by Daniel Huang on 6/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit
import Parse


class AddStudentLinkViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var shareLink: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    var userLocation: [String: String]! //includes udacity id, location, first and last name...
    var coords: CLLocationCoordinate2D?
    
    func findAddressByLocation() {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(userLocation["location"]!) { (placemarks, error) in
            if error != nil {
                print("Geocode failed with error: \(error!.localizedDescription)")
            } else if placemarks?.count > 0 {
                let placemark = placemarks![0]
                let location = placemark.location
                self.coords = location!.coordinate
                
                self.showMap()
            }
        }
    }
    
    
    @IBAction func saveSubmissionToParse(sender: AnyObject) {
        let location = PFObject(className:"Location")
        
        location["student_id"] = userLocation["id"]
        location["firstName"] =  userLocation["firstName"]
        location["lastName"] =  userLocation["lastName"]
        location["coordinates"] = userLocation["location"]
        location["sharedLink"] = shareLink.text!
        
        location.saveInBackgroundWithBlock { (success, error) in
            if let error = error {
                print(error)
            } else if success {
                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: {
                    
                })
            }
        }
    }
    
    
    func showMap() {
        let latDelta: CLLocationDegrees = 0.1
        let lonDelta: CLLocationDegrees = 0.1
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coords!, span: span)
        
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords!
        annotation.title = userLocation["location"]!
        
        map.addAnnotation(annotation)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        findAddressByLocation()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
