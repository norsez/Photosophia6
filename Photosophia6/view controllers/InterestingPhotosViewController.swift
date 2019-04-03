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

class InterestingPhotosViewController: UICollectionViewController, ViewRxProtocol {
   
    let viewModel = InterestingPhotoViewModel()
    let disposeBag = DisposeBag()
    let CELLID = "thumbnail cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createCallbacks()
        self.bindViewToViewModel()
        self.viewModel.loadPhotos()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.photos.value.count
    }
    
    
    
    
    //MARK: Rx
    func createCallbacks() {
        self.viewModel.photos.subscribe(onNext: { (photos) in
            self.collectionView.reloadData()
        }).disposed(by: self.disposeBag)
    }
    
    func bindViewToViewModel() {
//        self.collectionView.dataSource = nil
//        self.collectionView.delegate = nil
//
//        self.viewModel.photos
//            .bind(to: collectionView.rx.items(cellIdentifier: self.CELLID, cellType: ThumbnailCell.self)) { (row, photo, cell) in
//                if let url = photo.photoURL(with: .th100) {
//                    cell.imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
//                }
//        }.disposed(by: self.disposeBag)
    }
    
}
