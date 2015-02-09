//
//  ResultsViewController.swift
//  MarylouiOS
//
//  Created by Franklin Schrans on 07/02/2015.
//  Copyright (c) 2015 Franklin Schrans. All rights reserved.
//

import UIKit
import MapKit

class ResultsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var avgLoc : CLLocationCoordinate2D!
    var cities : Array<String!> = []
    var geoLocs : Array<String!> = []
    var geoLocsCoords : Array<(Double!, Double!)> = []
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                println("Swiped down")
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var addStatusBar = UIView()
        
        addStatusBar.frame = CGRectMake(0, 0, 320, 20);
        
        addStatusBar.backgroundColor = UIColor(red: 247, green: 247, blue: 247, alpha: 1)
        
        self.view.addSubview(addStatusBar)
                
        cities = NSUserDefaults.standardUserDefaults().objectForKey("cities") as Array<String!>
        geoLocs = NSUserDefaults.standardUserDefaults().objectForKey("geolocs") as Array<String!>
        
        println("Fetched \(cities)")
        println("Fetched \(geoLocs)")
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "protoCell")
        
        geoLocsCoords = [];
        
        convertGeoLocs()
        
        initialiseMap()
        
        println(geoLocsCoords);
    }
    
    func convertGeoLocs() {
        for var i : Int = 0 ; i < geoLocs.count ; i++ {
            geoLocsCoords.append(processLocs(geoLocs[i]))
        }
    }
    
    func calculateAvg(locations : Array<CLLocationCoordinate2D>) {
        var avgX : Int = 0
        var avgY : Int = 0
        let length = locations.count
        
        println(length)
        
        for var i : Int = 0; i < length; i++ {
            avgX += Int(locations[i].longitude)
            avgY += Int(locations[i].latitude)
        }
        
        avgX /= length
        avgY /= length
        
        var newX  : CLLocationDegrees = CLLocationDegrees(avgX)
        var newY : CLLocationDegrees = CLLocationDegrees(avgY)
        
        self.avgLoc = CLLocationCoordinate2D(latitude: newX, longitude: newY)

    }
    
    func initialiseMap() {
        var geoLocCL : Array<CLLocationCoordinate2D> = []
        
        let (lat, long) = geoLocsCoords[0]
        
        var loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        var topAnnot = putPinAt(loc, i: 0)
        
        geoLocCL.append(loc)
        
        for var i : Int = 1 ; i < cities.count; i++ {
            
            let (lat, long) = geoLocsCoords[i]
            
            var loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            putPinAt(loc, i: i)
            
            geoLocCL.append(loc)
        }
        
        cityName.text = cities[0]
        
        var span : MKCoordinateSpan = MKCoordinateSpanMake(2, 2)
        
        var region = MKCoordinateRegion(center: geoLocCL[0], span: span )
        
        mapView.setRegion(region, animated: true)
        
        mapView.selectAnnotation(topAnnot, animated: true)
        
        println("Geo \(geoLocCL)")
    }
    
    func putPinAt(loc : CLLocationCoordinate2D, i : Int) -> MKPointAnnotation {
        var annotation = MKPointAnnotation()
        
        annotation.setCoordinate(loc)
        annotation.title = cities[i]
        
        if (i == 0) {
            annotation.subtitle = "Top Result"
        } else {
            annotation.subtitle = "Result \(i + 1)"
        }
        
        mapView.addAnnotation(annotation)
        
        return annotation
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("protoCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.cities[indexPath.row]
        
        let image : UIImage! = UIImage(named: (String(indexPath.row + 1)) + "circle.png")
        
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.15, 0.15))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.imageView?.image = scaledImage
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedIndexPath : NSIndexPath = tableView.indexPathForSelectedRow()!
        
        updateMapWithFocusOn(selectedIndexPath.row)
    }
    
    func updateMapWithFocusOn(index : Int) {
        
        let (lat,long) = geoLocsCoords[index]
        
        var focusLoc : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        var region1 = MKCoordinateRegion(center: focusLoc, span: MKCoordinateSpanMake(2, 2))
        
        var annot = MKPointAnnotation()
        annot.setCoordinate(focusLoc)
        
        //mapView.selectAnnotation(annot, animated: true)

        mapView.setRegion(region1, animated: true)
        
        self.cityName.text = cities[index]
    }

    func processLocs(s : String) -> (Double!, Double!) {
        println(s)
        
        var tmpLat : String  = ""
        var tmpLong : String = ""
        var lat : Double = 0
        var long : Double = 0
        
        for var i : Int = 0 ; i < countElements(s) ; i++ {
            if (s[i] == ",") {
                lat = (tmpLat as NSString).doubleValue
                tmpLong = "";
                continue
            }
            
            tmpLat += s[i]
            tmpLong += s[i]
        }
        
        long = (tmpLong as NSString).doubleValue
        
        return (lat, long)
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

