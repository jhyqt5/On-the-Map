//
//  ListViewController.swift
//  OnTheMapUdacity
//
//  Created by Daniel Huang on 6/17/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse


class ListViewController: UIViewController, UITableViewDelegate {
    
    //student information
    var id: String = (UIApplication.sharedApplication().delegate as! AppDelegate).userID!
    var lastName: String!
    var firstName: String!
    
    //location init
    var locations = [String]()
    var names = [String]()
    var links = [String]()
    
    @IBOutlet weak var table: UITableView!
    
    @IBAction func refreshTable(sender: AnyObject) {
        locations.removeAll()
        names.removeAll()
        links.removeAll()
        
        getListLocations()
        table.reloadData()
    }
    
    //Prepping for Segue
    
    func  getUserInfo() {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(id)")!)
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
    
    
    @IBAction func createMapAnnotation(sender: AnyObject) {
        performSegueWithIdentifier("showSetLocation", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSetLocation" {
            let vc = segue.destinationViewController as! SetLocationViewController
            
            vc.userInfo = ["id" : id, "firstName" : firstName, "lastName" : lastName]
            
        }
    }
    
    
    // List of Student and Links
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("linkCell", forIndexPath: indexPath)
        
        cell.imageView!.image = UIImage(named: "pin-icon.png")
        cell.textLabel?.text = names[indexPath.row]
        cell.detailTextLabel?.text = links[indexPath.row]
        
        return cell
    } // end function
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = links[indexPath.row] as String!
        UIApplication.sharedApplication().openURL(NSURL(string: link)!)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func  getListLocations() {
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
                }
                
                self.table.reloadData()
            } else {
                print(error)
            }
        } //end query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getListLocations()
        getUserInfo()
        table.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }

} //end controller
