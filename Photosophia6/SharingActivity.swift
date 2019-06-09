//
//  SharingActivity.swift
//  Photosophia6
//
//  Created by norsez on 9/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import Kingfisher

class ActivityOpenInFlickr: UIActivity {
    let photo: Photo
    init(with photo: Photo) {
        self.photo = photo
    }
    
    override var activityTitle: String? {
        return "Flickr"
    }
    
    override var activityType: UIActivity.ActivityType? {
        return ActivityType(rawValue: "Flickr")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override var activityImage: UIImage?{
        get {
            return UIImage(named: "activity flickr")
        }
    }
    
    override func perform() {
        if let url = self.photo.photoWebURL  {
            UIApplication.shared.open(url, options: [:]) { (success) in
                self.activityDidFinish(success)
            }
        }
    }
    
}

extension UIViewController {
    func share(photo: Photo) -> UIActivityViewController {
        let activities: [UIActivity] = [
            ActivityOpenInFlickr(with: photo)
        ]
        
        var image = UIImage()
        if let dataURL = photo.photoURL(with: .l1024) {
            
            if let img = ImageCache.default.retrieveImageInMemoryCache(forKey: dataURL.absoluteString) {
                image = img
            }
        }
        let urlString =  photo.photoWebURL?.absoluteString ?? ""
        let text = "\(photo.title ?? "untitled") by \(photo.ownername ?? "unknown")  \(urlString))"
        
        let ctrl = UIActivityViewController(activityItems: [photo, image, text], applicationActivities: activities)
        ctrl.completionWithItemsHandler = {
            (type, completed, returnedItems, error) in 
        }
        return ctrl
    }
}
