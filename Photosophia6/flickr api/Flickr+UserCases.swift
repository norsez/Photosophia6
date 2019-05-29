//
//  Flickr+UserCases.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import Foundation
import RxSwift
import SwiftyJSON
import FlickrKit

//MARK: use cases
extension Flickr {
    
    func loadInterestingPhotos(withEachGroupLimitTo limit: Int) -> Observable<[Photo]> {
        return Observable.create({ (observer) -> Disposable in
            
            self.getAllUserGroups()
//                .debug()
                .observeOn(self.serialSchd)
                .subscribe(onNext: { (groups) in
                    var allGroupOps = [Observable<[Photo]>]()
                    for e in groups.shuffled().enumerated() {
                        allGroupOps.append( self.getInterestingPhotos(in: e.element, limit: limit) )
                    }
                    
                    var progressGroup = Float(0)
                    let totalGroups = Float(groups.count)
                    self.progress.onNext(0)
                    
                    Observable.concat(allGroupOps)
//                        .debug()
                        .observeOn(self.serialSchd)
                        .subscribe(onNext: { (photos) in
                            observer.onNext(photos)
                            
                            progressGroup = progressGroup.advanced(by: 1)
                            self.progress.onNext(progressGroup/totalGroups)
                            
                        }, onError: { (error) in
                            observer.onError(error)
                        }, onCompleted: {
                            self.progress.onNext(0)
                            observer.onCompleted()
                        })
                        .disposed(by: self.disposeBag)
                    
                    
                }, onError: { (error) in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        })
    }
    
    
    //when not logged in, we used photosophia groups
    func loadPhotosophiaInterestingGroupPhotos() -> Observable<Photos> {
        return Observable.create({ (observer) -> Disposable in
            
            self.call(method: "flickr.favorites.getPublicList",
                             args: ["user_id": Constants.USERID_PHOTOSOPHIA,
                                "extras": "url_b, url_c"
                ],
                             topJSONKey: "photos" )
                .subscribe(onNext: { (photos: Photos) in
                    
                    observer.onNext(photos)
                    observer.onCompleted()
                })
            .disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        })
    }
}

