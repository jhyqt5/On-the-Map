//
//  MapViewController.swift
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




class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    //student info
    var userID: String!
    var lastName: String!
    var firstName: String!
    
    //location init
    var locations = [String]()
    var names = [String]()
    var links = [String]()
    
    //mapkit
    var coords: CLLocationCoordinate2D!
    
    @IBAction func createMapAnnotation(sender: AnyObject) {
        performSegueWithIdentifier("showSetLocation", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSetLocation" {
            let vc = segue.destinationViewController as! SetLocationViewController
            
            vc.userInfo = ["id" : userID, "firstName" : firstName, "lastName" : lastName]
            
        }
    }
    
    func getStudentMapLocations(){
        let query = PFQuery(className: "Location")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        
                        //get locations
                        if let place = object["coordinates"] {
                            self.locations.append(place as! String)
                        }
                        
                        //get names
                        if let firstname = object["firstName"] {
                            if let lastname = object["lastName"] {
                                self.names.append("\(firstname as! String) \(lastname as! String)")
                            }
                        }
                        
                        //get links
                        if let link = object["sharedLink"] {
                            self.links.append(link as! String)
                        }
                    }
                    
                    self.addItemsMaps()
                    
                }
            } else {
                print(error)
            }
        } //end query
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the user info
        getUserInfo()
        findStudent()
        map.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getStudentMapLocations()
    }
    
    func findStudent() {
        //find user, if not exist, create
        
        let query = PFQuery(className:"Student")
        query.whereKey("student_id", equalTo: userID!)
        query.findObjectsInBackgroundWithBlock { (students, error) in
            if let error = error {
                print(error)
            } else if let students = students {
                if students == [] {
                    self.createStudent()
                }
            }
        }
    }
    
    func createStudent(){
        let student = PFObject(className:"Student")
        
        student["student_id"] = userID
        student["firstName"] = firstName
        student["lastName"] = lastName
        
        try! student.save()
    } // end func
    
    func getUserInfo() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                return
            }
            dispatch_async(dispatch_get_main_queue(),{
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let json: NSDictionary?
                
                do {
                    try json = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                } catch let parseError as NSError {
                    print(parseError)
                    return
                }
                
                guard let userDict = json?["user"] as? [String: AnyObject]
                    else {
                        return
                }
                
                if let slastname = userDict["last_name"] as? String {
                    if let sfirstname = userDict["first_name"] as? String {
                        self.lastName = slastname
                        self.firstName = sfirstname
                    }
                }
            }) //end dispatch
        } // end task
        
        task.resume()
    }
    
    var i = 0
    
    func addItemsMaps() {

        
        while i < locations.count {
            let geoCoder = CLGeocoder()
            
            geoCoder.geocodeAddressString(locations[i]) { (placemarks, error) in
                if error != nil {
                    print("Geocode failed with error: \(error!.localizedDescription)")
                } else if placemarks?.count > 0 {
                    let placemark = placemarks![0]
                    let location = placemark.location
                    self.coords = location!.coordinate
                    
                    
                    self.showMap()
                }
            }
            i = i + 1
        } //end while
    }
    
    
    func showMap() {
        let latDelta: CLLocationDegrees = 50
        let lonDelta: CLLocationDegrees = 50
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coords!, span: span)
        
    
        map.setRegion(region, animated: true)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords!
        annotation.title = names[0] //fatal error index out of range?
        annotation.subtitle = links[0] //fatal error index out of range?
        
        map.addAnnotation(annotation)
    }
    
    //add button
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true

            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            
            let link = (annotationView.annotation?.subtitle)! as String!
            
            UIApplication.sharedApplication().openURL(NSURL(string: link)!)
            
        }
    }
    

} //end controller
