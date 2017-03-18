//
//  LoginVC.swift
//  Uber Clone
//
//  Created by Mohammad Hemani on 3/17/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Parse

class LoginVC: UIViewController {

    @IBOutlet weak var usernameTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var loginOrSignupButton: MaterialButton!
    @IBOutlet weak var changeLoginSignupModeButton: MaterialButton!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    
    var logInMode = true
    var userMode = UserMode.Rider
    
    enum UserMode: String {
        case Rider = "Rider"
        case Driver = "Driver"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let isDriver = PFUser.current()?["isDriver"] as? String {
            
            if isDriver == "Driver" {
                
                
                
            } else {
                
                performSegue(withIdentifier: "RiderVC", sender: self)
                
            }
            
        }

        
    }
    
    @IBAction func loginSignupTapped(sender: UIButton) {
        
        if let username = usernameTextField.text, username != "", let password = passwordTextField.text, password != "" {
            
            if logInMode {
                
                PFUser.logInWithUsername(inBackground: username, password: password, block: { (user, error) in
                    
                    if let error = error as? NSError {
                        
                        var displayedErrorMessage = "Please try again later"
                        
                        if let parseError = error.userInfo["error"] as? String {
                            
                            displayedErrorMessage = parseError
                        }
                        
                        self.showErrorAlert(title: "Log In Failed", message: displayedErrorMessage)
                        
                    } else {
                        
                        print("Log In Successful")
                        
                    }
                    
                })
                
                
            } else {
                
                let user = PFUser()
                user.username = username
                user.password = password
                
                user["isDriver"] = userMode.rawValue
                
                user.signUpInBackground(block: { (success, error) in
                    
                    if let error = error as? NSError {
                        
                        var displayedErrorMessage = "Please try again later"
                        
                        if let parseError = error.userInfo["error"] as? String {
                            
                            displayedErrorMessage = parseError
                        }
                        
                        self.showErrorAlert(title: "Sign Up Failed", message: displayedErrorMessage)
                        
                    } else {
                        
                        print("Sign Up Successful")
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? String {
                            
                            if isDriver == "Driver" {
                                
                                
                                
                            } else {
                                
                                self.performSegue(withIdentifier: "RiderVC", sender: self)
                                
                            }
                            
                        }
                        
                    }
                    
                })
                
            }
            
        } else {
            
            showErrorAlert(title: "Error in Form", message: "Username and Password are required")
            
        }
        
        
        
    }
    
    @IBAction func changeLoginSignupModeTapped(sender: UIButton) {
        
        if logInMode {
            
            logInMode = false
            
            loginOrSignupButton.setTitle("Sign Up", for: .normal)
            
            changeLoginSignupModeButton.setTitle("Switch To Log In", for: .normal)
            
            riderDriverSwitch.isHidden = false
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            
        } else {
            
            logInMode = true
            
            loginOrSignupButton.setTitle("Log In", for: .normal)
            
            changeLoginSignupModeButton.setTitle("Switch To Sign Up", for: .normal)
            
            riderDriverSwitch.isHidden = true
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            
        }
        
    }

    @IBAction func riderDriverValueChanged(_ sender: UISwitch) {
        
        if riderDriverSwitch.isOn {
            
            userMode = UserMode.Driver
            
        } else {
            
            userMode = UserMode.Rider
            
        }
        
    }
    
}

