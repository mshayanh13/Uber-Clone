//
//  Constants.swift
//  Uber Clone
//
//  Created by Mohammad Hemani on 3/17/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0


extension UIViewController {
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}
