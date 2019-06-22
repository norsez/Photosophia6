//
//  DevMode.swift
//  Photosophia6
//
//  Created by norsez on 22/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DevMode {
    static var instance = DevMode()
    private init() {}
    
    func start() {
        #if DEBUG
        if let app = UIApplication.shared.delegate as? AppDelegate,
            let vc = app.window?.rootViewController {
            let taps = UITapGestureRecognizer(target: self, action: #selector(showDevMode))
            taps.numberOfTapsRequired = 4
            vc.view.addGestureRecognizer(taps)
        }
        #endif
    }
    
    @objc func showDevMode() {
        if let app = UIApplication.shared.delegate as? AppDelegate,
            let nav = app.window?.rootViewController as? UINavigationController {
            let ctrl = UIViewController(nibName: nil, bundle: nil)
            nav.pushViewController(ctrl, animated: true)
        }
    }
}
