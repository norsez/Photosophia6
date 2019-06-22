//
//  Alert+UIViewController.swift
//  Photosophia6
//
//  Created by norsez on 29/5/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import Whisper
import RxSwift

struct UIStatus {
    
    static let needsLogin = PublishSubject<()>()
    
    static let handleError = { (error: Error) -> () in
        if error is FlickrError{
          let error = error as! FlickrError
            if error == FlickrError.insufficientPermission {
               UIStatus.needsLogin.onNext(())
            }
        }else {
            UIStatus.showStatusError(text: "\(error)")
        }
    }
    
    static func showStatus(text: String) {
        //let m = Murmur(title: text, backgroundColor: UIColor.black.withAlphaComponent(0.25), titleColor: UIColor.lightText, font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize), action: nil)
        let m = Message(title: text, textColor: UIColor.lightText, backgroundColor: UIColor.black.withAlphaComponent(0.25), images: nil)
        if let app = UIApplication.shared.delegate as? AppDelegate,
            let nav = app.window?.rootViewController as? UINavigationController {
        Whisper.show(whisper: m, to: nav, action: .show)
        }
    }
    
    static func showStatusError(text: String) {
        let m = Murmur(title: text, backgroundColor: UIColor.red, titleColor: UIColor.yellow, font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize), action: nil)
        Whisper.show(whistle: m)
    }
}

