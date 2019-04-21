//
//  InterestingPhotosViewController+PhotoBrowser.swift
//  Photosophia6
//
//  Created by norsez on 21/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import SKPhotoBrowser

extension InterestingPhotosViewController {
    func showPhoto(from indexPath: IndexPath) {
        let skPhotos = self.viewModel.photos.value.compactMap { (p) -> SKPhoto? in
            let sk_photo = SKPhoto.photoWithImageURL(p.url_c ?? "")
            sk_photo.shouldCachePhotoURLImage = true
            let caption = self.viewModel.caption(of: p)
            sk_photo.caption = caption
            return sk_photo
        }
        
        let browser = SKPhotoBrowser(photos: skPhotos, initialPageIndex: indexPath.row)
        self.present(browser, animated: true, completion: nil)
    }
}
