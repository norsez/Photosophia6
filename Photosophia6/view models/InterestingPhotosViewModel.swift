//
//  InterestingPhotosViewModel.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxSwift
import RxCocoa

class InterestingPhotoViewModel {
    let loginViewModel = LoginViewModel()
    let photos = BehaviorRelay<[Photo]>(value: [])
    let disposeBag = DisposeBag()
    let api = Flickr.shared
    let MAX_PER_GROUP = 5
    
    let onError = BehaviorRelay<String?>(value:nil)
    let onStatus = BehaviorRelay<String?>(value:nil)
    
    
    func loadPhotos() {
        self.onStatus.accept("loading…")
        self.api.loadInterestingPhotos(withEachGroupLimitTo: self.MAX_PER_GROUP)
            .subscribe(onNext: { [weak self] (photo) in
                if let _self = self {
                    var photos = _self.photos.value
                    photos.append(photo)
                    _self.photos.accept(photos)
                }
            })
        .disposed(by: self.disposeBag)
    }
    
    
}
