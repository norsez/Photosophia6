//
//  Alert+UIViewController.swift
//  Photosophia6
//
//  Created by norsez on 29/5/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import Whisper


extension UIViewController {
    func showStatus(text: String) {
        let m = Murmur(title: text, backgroundColor: UIColor.black.withAlphaComponent(0.25), titleColor: UIColor.lightText, font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize), action: nil)
        Whisper.show(whistle: m)
    }
    
    func showStatusError(text: String) {
        let m = Murmur(title: text, backgroundColor: UIColor.red, titleColor: UIColor.yellow, font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize), action: nil)
        Whisper.show(whistle: m)
    }
}
