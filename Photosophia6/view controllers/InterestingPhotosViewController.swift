//
//  InterestingPhotosViewController.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import Kingfisher

//class PhotoLayout:NSObject, UICollectionViewDelegateFlowLayout {
//
//
//
//    override init() {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width
//        let cellWidth = (width - 16) / 5 // compute your cell width
//        return CGSize(width: cellWidth, height: cellWidth )
//
//    }
//}

class InterestingPhotosViewController: UICollectionViewController, ViewRxProtocol, UICollectionViewDelegateFlowLayout {
   
    let viewModel = InterestingPhotoViewModel()
    let disposeBag = DisposeBag()
    let CELLID = "thumbnail cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createCallbacks()
        self.bindViewToViewModel()
        
        self.confirmAuth()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.photos.value.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.CELLID, for: indexPath) as! ThumbnailCell
        if let photoUrl = self.viewModel.photos.value[indexPath.row].photoURL(with:.th100) {
            cell.imageView.kf.setImage(with: photoUrl, options: [.transition(.fade(0.2))] )
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showPhoto(from: indexPath)
    }
    
    func showFlickrAuthFlow() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let ctrl = sb.instantiateViewController(withIdentifier: "auth webview") as! AuthWebViewController
        self.present(ctrl, animated: true, completion: nil)
    }
    
    //MARK: Rx
    func createCallbacks() {
        
        self.viewModel.photos
            .subscribe(onNext: { (photos) in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindViewToViewModel() {
        //collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = (width - 0) / 5 // compute your cell width
        return CGSize(width: cellWidth, height: cellWidth )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
