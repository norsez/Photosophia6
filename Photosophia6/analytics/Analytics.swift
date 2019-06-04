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
    
    
    enum Event: String {
        case loadSamplePhotos
        case loadPhotos
        case selectPhoto
        case sharePhoto
    }
    
    func log(event: Event, group: Group? = nil, photo: Photo? = nil) {
        var parameters = [String:String]()
        if let g = group,
            let n = g.name,
            let id = g.id{
            parameters["group_name"] = n
            parameters["group_id"] = id
        }
        
        if let p = photo,
            let id = p.id{
            parameters["photo_id"] = id
        }
        
        Firebase.Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    func initialize() {
        FirebaseApp.configure()
        
    }
    
    static let shared = Analytics()
    private init() {}
}
