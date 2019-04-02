//
//  ViewProtocol.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ViewRxProtocol: UIViewController {
    func createCallbacks()
    func bindViewToViewModel()
}
