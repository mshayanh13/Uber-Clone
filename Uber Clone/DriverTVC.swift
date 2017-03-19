//
//  DriverTVC.swift
//  Uber Clone
//
//  Created by Mohammad Hemani on 3/19/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Parse

class DriverTVC: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var requestUsernames: [String]!
    var requestLocations: [CLLocationCoordinate2D]!
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        requestUsernames = [String]()
        requestLocations = [CLLocationCoordinate2D]()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestUsernames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //Find distance between user location and requestLocation[indexPath.row]
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let riderCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        
        cell.textLabel?.text = "\(requestUsernames[indexPath.row]) - \(roundedDistance)km away"

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DriverLogoutSegue" {
            
            locationManager.stopUpdatingLocation()
            
            PFUser.logOut()
            
            self.navigationController?.navigationBar.isHidden = true
            
        } else if segue.identifier == "RiderLocationVC" {
            
            if let row = tableView.indexPathForSelectedRow?.row {
                
                if let destination = segue.destination as? RiderLocationVC {
                    
                    destination.requestLocation = requestLocations[row]
                    destination.requestUsername = requestUsernames[row]
                }
                
            }
            
            
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            
            userLocation = location
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            
            query.limit = 10
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    self.requestUsernames.removeAll()
                    self.requestLocations.removeAll()
                    
                    for riderRequest in riderRequests {
                        
                        print("Results")
                        
                        if let username = riderRequest["username"] as? String {
                            
                            if riderRequest["driverResponded"] == nil {
                            
                                if let riderRequestLocation = riderRequest["location"] as? PFGeoPoint {
                                    self.requestUsernames.append(username)
                                    self.requestLocations.append(CLLocationCoordinate2D(latitude: riderRequestLocation.latitude, longitude: riderRequestLocation.longitude))
                                }
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                } else {
                    
                    print("No results")
                    
                }
                
            })
            
        }
        
    }

}
