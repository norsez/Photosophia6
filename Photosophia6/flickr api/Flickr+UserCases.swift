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
    
    func loadInterestingPhotos(withEachGroupLimitTo limit: Int) -> Observable<Photo> {
        return self.getAllUserGroups()
            .map { (g) -> String in
                g.id!
            }.flatMap { (groupId) -> Observable<Photo> in
                return self.getInterestingPhotos(in: groupId, limit: limit)
        }
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

