//
//  Analytics.swift
//  Photosophia6
//
//  Created by norsez on 1/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class Analytics {
    
    func initialize() {
        FirebaseApp.configure()
        
    }
    
    static let shared = Analytics()
    private init() {}
}
