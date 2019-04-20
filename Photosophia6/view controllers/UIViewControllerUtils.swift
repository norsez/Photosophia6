//
//  UIViewControllerUtils.swift
//  Photosophia6
//
//  Created by norsez on 1/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(message: String, then: (()->())? = nil) {
        print(message)
        let ctrl = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        ctrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let then = then  {
                then ()
            }
        }))
        self.present(ctrl, animated: true, completion: nil)
    }
    
    func alert(error message: String, then: (()->())? = nil) {
        print(message)
        let ctrl = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ctrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let then = then  {
                then ()
            }
        }))
        self.present(ctrl, animated: true, completion: nil)   
    }
    
    func log(_ message: String) {
        print(message)
    }
}
