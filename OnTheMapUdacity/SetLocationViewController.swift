//
//  SetLocationViewController.swift
//  OnTheMapUdacity
//
//  Created by Daniel Huang on 6/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit

class SetLocationViewController: UIViewController {
    
    var userInfo: [String: String]!
    
    @IBOutlet weak var location: UITextField!
    
    
    @IBAction func findAddress(sender: AnyObject) {
        performSegueWithIdentifier("addStudentLink", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addStudentLink" {
            let vc = segue.destinationViewController as! AddStudentLinkViewController
            userInfo["location"] = location.text
            vc.userLocation = userInfo!
        }
    }
        
    @IBAction func cancelSetLocation(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
