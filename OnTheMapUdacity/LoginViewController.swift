/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {
    var id: String!

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    
    @IBAction func login(sender: AnyObject) {
        
        if errorMessage.text != nil {
            errorMessage.text = ""
        }
        
        //Note: make sure you pass information with force unwrap.
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email.text!)\", \"password\": \"\(password.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
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
                    
                    guard let userDict = json?["account"] as? [String: AnyObject]
                        else {
                            return
                    }
                    
                    if let key = userDict["key"] as? String {
                        let object = UIApplication.sharedApplication().delegate
                        let appDelegate = object as! AppDelegate
                        appDelegate.userID = key
                        
                    }
                    
                    self.completeLogin()

                })
            
            }
        
        task.resume()
        
    } //end action
    

    func completeLogin() {
        performSegueWithIdentifier("showMap", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let TabBarVC = segue.destinationViewController as! UITabBarController
            let NavVC = TabBarVC.viewControllers![0] as! UINavigationController
            let destinationVC = NavVC.viewControllers[0] as! MapViewController
            destinationVC.userID = (UIApplication.sharedApplication().delegate as! AppDelegate).userID
        }
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    
} //end controller
