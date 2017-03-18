//
//  RiderVC.swift
//  Uber Clone
//
//  Created by Mohammad Hemani on 3/17/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var uberButton: UIButton!
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var riderRequestActive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        uberButton.isHidden = true
        let query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if objects != nil {
                    
                self.riderRequestActive = true
                self.uberButton.setTitle("Cancel Uber", for: .normal)
                
                
            }
            
            self.uberButton.isHidden = false
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LogoutSegue" {
            
            PFUser.logOut()
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.map.setRegion(region, animated: true)
            
            self.map.removeAnnotations(self.map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation
            annotation.title = "Your Location"
            self.map.addAnnotation(annotation)
            
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                        riderRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                        riderRequest.saveInBackground()
                        
                    }
                    
                }
                
            })
            
        }
        
    }
    
    @IBAction func uberButtonTapped(sender: UIButton) {
        
        if riderRequestActive {
            
            uberButton.setTitle("Call An Uber", for: .normal)
            riderRequestActive = false
            
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                            
                        riderRequest.deleteInBackground()
                        
                    }
                    
                }
                
            })
            
        } else {
            
            if userLocation.longitude != 0 && userLocation.latitude != 0 {
                
                riderRequestActive = true
                uberButton.setTitle("Cancel Uber", for: .normal)
                
                let riderRequest = PFObject(className: "RiderRequest")
                riderRequest["username"] = PFUser.current()?.username
                riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                riderRequest.saveInBackground(block: { (success, error) in
                    
                    if success {
                        
                        print("Called An Uber")
                        
                    } else {
                        
                        self.uberButton.setTitle("Call An Uber", for: .normal)
                        self.riderRequestActive = false
                        
                        self.showErrorAlert(title: "Could not call Uber", message: "Please try again!")
                        
                    }
                    
                })
                
            } else {
                
                self.showErrorAlert(title: "Could not call Uber", message: "Cannot detect your location.")
                
            }
            
        }
        
    }

}
