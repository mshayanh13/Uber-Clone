//
//  RiderLocationVC.swift
//  Uber Clone
//
//  Created by Mohammad Hemani on 3/19/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderLocationVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptRequestButton: MaterialButton!

    
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestUsername = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: requestLocation.latitude, longitude: requestLocation.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestUsername
        map.addAnnotation(annotation)
        
    }

    @IBAction func acceptRequestButtonTapped(sender: UIButton) {
        
        let query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: requestUsername)
        query.findObjectsInBackground { (objects, error) in
            
            if let riderRequests = objects {
                
                for riderRequest in riderRequests {
                    
                    riderRequest["driverResponded"] = PFUser.current()?.username
                    riderRequest.saveInBackground()
                    
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        
                        if let placemarks = placemarks, placemarks.count > 0 {
                            
                            let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                            
                            let mapItem = MKMapItem(placemark: mKPlacemark)
                            mapItem.name = self.requestUsername
                            
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                            mapItem.openInMaps(launchOptions: launchOptions)
                            
                        }
                        
                    })
                    
                }
                
            }
            
        }
        
    }

}
