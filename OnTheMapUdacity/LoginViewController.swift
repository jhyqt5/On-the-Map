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
        
        print(request)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            
            // handle data
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    } //end action
    
}
