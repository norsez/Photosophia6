//
//  InterestingPhotosViewController+PhotoBrowser.swift
//  Photosophia6
//
//  Created by norsez on 21/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import RxKingfisher
import Kingfisher
import RxSwift
//
//class PhotoActivityProvider: UIActivityItemProvider {
//    let photo: Photo
//    init(with photo: Photo) {
//        self.photo = photo
//        super.init(placeholderItem: photo)
//    }
//
//    override var item: Any {
//        get {
//            return self.photo.photoWebURL as Any
//        }
//    }
//}
//
class PhotoToDisplay: NSObject, NYTPhoto {


    let originalPhoto: Photo
    init(with originalPhoto: Photo) {
        self.originalPhoto = originalPhoto
    }

    var image: UIImage?

    var imageData: Data?

    var placeholderImage: UIImage?

    var attributedCaptionTitle: NSAttributedString?

    var attributedCaptionSummary: NSAttributedString?

    var attributedCaptionCredit: NSAttributedString?

}

extension InterestingPhotosViewController: NYTPhotosViewControllerDelegate, NYTPhotoViewerDataSource {
    //delegate
    var numberOfPhotos: NSNumber? {
        return NSNumber(integerLiteral:  self.viewModel.photos.value.count)
    }
    
    func index(of photo: NYTPhoto) -> Int {
        for index in 0..<self.viewModel.photos.value.count {
            if let mp = photo as? PhotoToDisplay {
                let op = self.viewModel.photos.value[index]
                if op.id == mp.originalPhoto.id {
                    return index
                }
            }
        }
        
        return NSNotFound
    }
    
    func photo(at photoIndex: Int) -> NYTPhoto? {
        let photo = self.viewModel.photos.value[photoIndex]
        let nytPhoto = PhotoToDisplay(with: photo)
        
        if let thumbUrl = photo.photoURL(with: .th100) {
            nytPhoto.placeholderImage = ImageCache.default.retrieveImageInMemoryCache(forKey: thumbUrl.absoluteString )
        }
        
        if let dataURL = photo.photoURL(with: .l1024) {
            do {
                if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: dataURL.absoluteString) {
                    nytPhoto.image = image
                }else {
                    nytPhoto.imageData = try Data(contentsOf: dataURL)
                }
            }catch {
                Logger.log("\(error)")
            }
        }
        
        return nytPhoto
    }

    
    func showPhoto(from indexPath: IndexPath) {
        self.selectedPhotoIndex = indexPath.item
        let ctrl = NYTPhotosViewController(dataSource: self, initialPhotoIndex: self.selectedPhotoIndex ?? 0, delegate: self)
        self.present(ctrl, animated: true, completion: nil)

    }
    
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, handleActionButtonTappedFor photo: NYTPhoto) -> Bool {
        
        let photo = self.viewModel.photos.value[self.selectedPhotoIndex ?? 0]
        if let url = photo.photoWebURL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        //ShareActivity.shared.share(photo: photo, on: photosViewController)
        
        return true
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, maximumZoomScaleFor photo: NYTPhoto) -> CGFloat {
        return 8
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, captionViewFor photo: NYTPhoto) -> UIView? {
        let index = self.index(of: photo)
        let photo = self.viewModel.photos.value[index]
        
        var text = ""
        if let title = photo.title {
            text = title
        }
        if let ownerName = photo.ownername {
            text += " by \(ownerName)"
        }
        if let group = photo.inGroup,
            let groupName = group.name {
            text += " in \(groupName)"
        }
        
        self.lightboxLabel.text = text
        
        return self.lightboxCaptionView
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, captionViewRespectsSafeAreaFor photo: NYTPhoto) -> Bool {
        return true
    }
    
    //MARK: image caching
    private func _cachgeImage(at index: Int) {
        if index >= 1 && index < self.viewModel.photos.value.count {
            let p = self.viewModel.photos.value[index]
            if let url = p.photoURL(with: .original) {
                KingfisherManager.shared.rx.retrieveImage(with: url)
                    .subscribe(onSuccess: { (_) in
                        Logger.log("cached image \(index)")
                    }) { (_) in
                        Logger.log("error caching \(index)")
                    }.disposed(by: self.disposeBag)
                
            }
        }
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, didNavigateTo photo: NYTPhoto, at photoIndex: UInt) {
        self._cachgeImage(at: Int(photoIndex) - 1)
        self._cachgeImage(at: Int(photoIndex) + 1)
    }
    
}
