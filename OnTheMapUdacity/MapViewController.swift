//
//  MapViewController.swift
//  OnTheMapUdacity
//
//  Created by Daniel Huang on 6/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    //student info
    var userID: String!
    var lastName: String!
    var firstName: String!
    
    //location init
    var longitude: CLLocation!
    var latitude: CLLocation!
    var latDelta: CLLocation!
    var lonDelta: CLLocation!
    var span: MKCoordinateSpan!
    var location: CLLocationCoordinate2D!
    var region: MKCoordinateRegion!
    
    
    @IBAction func createMapAnnotation(sender: AnyObject) {
        performSegueWithIdentifier("showSetLocation", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSetLocation" {
            let vc = segue.destinationViewController as! SetLocationViewController
            
            vc.userInfo = ["id" : userID, "firstName" : firstName, "lastName" : lastName]
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the user info
        getUserInfo()
        findStudent()
    
        
        //get student locations and add to map
        
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
    
    



} //end controller
