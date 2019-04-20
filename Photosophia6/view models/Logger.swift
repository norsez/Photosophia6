//
//  Logger.swift
//  Photosophia6
//
//  Created by norsez on 21/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class Logger {
    static let onLoggin = BehaviorRelay<String?>(value:nil)
    
    static func log(_ message: String){
        Logger.onLoggin.accept(message)
    }
}
