//
//  ShareActivity.swift
//  Photosophia6
//
//  Created by norsez on 28/5/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
class ShareActivity {
    
    class SharedPhoto: NSObject, UIActivityItemSource {
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return "placeholder text"
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            
            if let url = self.photo.photoWebURL {
                return url
            }else{
                return nil
            }
        }
        
        let photo: Photo
        init(photo: Photo) {
            self.photo = photo
        }
    }
    
    func share(photo: Photo, on viewController: UIViewController) {
        let sharedPhoto = SharedPhoto(photo: photo)
        let ctrl = UIActivityViewController(activityItems: [sharedPhoto], applicationActivities: nil)
        viewController.present(ctrl, animated: true, completion: nil)
    }
    
    
    static let shared = ShareActivity()
    private init() {}
    
}
