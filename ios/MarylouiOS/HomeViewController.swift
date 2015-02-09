//
//  ViewController.swift
//  MarylouiOS
//
//  Created by Franklin Schrans on 07/02/2015.
//  Copyright (c) 2015 Franklin Schrans. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    @IBOutlet weak var safetyField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var weatherField: UITextField!
    @IBOutlet weak var safetyView: UIView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var resultCities : Array<String!> = []
    var resultGeoLocs : Array<String!> = []
    
    @IBAction func search(sender: AnyObject) {
        var values : NSArray = [safetyField.text, priceField.text, weatherField.text]
        
        //println("Getting cities with values \(values)")
        
        // doHTTPPost()
        
        getResultsFromServerWithValues(values)

        //getResultsFromFileWithValues(values)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBOutlet weak var tableview: UITableView!
    
    func doHTTPPost() {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://www.freddielindsey.me:3000/testjson")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params = ["slevel":"I", "plevel" : "like", "wlevel" : "pie"] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
           // println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                //println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }
    
    func getResultsFromServerWithValues(NSArray) {
        DataManager.getDataFromServerWithSuccess { (ServerData) -> Void in
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2))
  //          dispatch_after(delayTime, dispatch_get_main_queue()){
            let json = JSON(data: ServerData)
            
           // println(json)

            for (key: String, subJson: JSON) in json {
                if let appName = json[key.toInt()!]["name"].stringValue as String? {
                    self.resultCities.append(appName)
                }
                
                if let appName = json[key.toInt()!]["geo"].stringValue as String? {
                    self.resultGeoLocs.append(appName)
                }
    //        }
            
            println("Got cities : \(self.resultCities)")
            println("Got geolocs : \(self.resultGeoLocs)")
            

            
            NSUserDefaults.standardUserDefaults().setObject(self.resultCities, forKey:"cities")
            NSUserDefaults.standardUserDefaults().setObject(self.resultGeoLocs, forKey:"geolocs")
            NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    func getResultsFromFileWithValues(NSArray) {
        DataManager.getTopAppsDataFromFileWithSuccess { (FileData) -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 5))
            dispatch_after(delayTime, dispatch_get_main_queue()){
                let json = JSON(data: FileData)
                
                // println(json)
                
                for (key: String, subJson: JSON) in json {
                    if let appName = json[key.toInt()!]["name"].stringValue as String? {
                        self.resultCities.append(appName)
                    }
                    
                    if let appName = json[key.toInt()!]["geo"].stringValue as String? {
                        self.resultGeoLocs.append(appName)
                    }
                }
                
                println("Got cities : \(self.resultCities)")
                println("Got geolocs : \(self.resultGeoLocs)")
                
                
                
                NSUserDefaults.standardUserDefaults().setObject(self.resultCities, forKey:"cities")
                NSUserDefaults.standardUserDefaults().setObject(self.resultGeoLocs, forKey:"geolocs")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

