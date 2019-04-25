//
//  InterestingPhotosViewController+PhotoBrowser.swift
//  Photosophia6
//
//  Created by norsez on 21/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class PhotoActivityProvider: UIActivityItemProvider {
    let photo: Photo
    init(with photo: Photo) {
        self.photo = photo
        super.init(placeholderItem: photo)
    }
    
    override var item: Any {
        get {
            return self.photo.photoWebURL as Any
        }
    }
}

extension InterestingPhotosViewController {
    func showPhoto(from indexPath: IndexPath) {
//        let skPhotos = self.viewModel.photos.value.compactMap { (p) -> SKPhoto? in
//            let sk_photo = SKPhoto.photoWithImageURL(p.url_c ?? "")
//            sk_photo.shouldCachePhotoURLImage = true
//            let caption = self.viewModel.caption(of: p)
//            sk_photo.caption = caption
//            return sk_photo
//        }
        let photo = self.viewModel.photos.value[indexPath.item]
        let skPhoto = SKPhoto.photoWithImageURL(photo.url_c ?? "")
        skPhoto.shouldCachePhotoURLImage = true
        skPhoto.caption = self.viewModel.caption(of: photo)
        let browser = SKPhotoBrowser(photos: [skPhoto], initialPageIndex: indexPath.row)
        browser.activityItemProvider = PhotoActivityProvider(with: photo)
        
        self.present(browser, animated: true, completion: nil)
    }
}
