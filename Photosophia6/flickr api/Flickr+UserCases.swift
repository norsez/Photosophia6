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
        return Observable.create({ (observer) -> Disposable in
            
            self.getAllUserGroups().subscribe(onNext: { (group) in
                
                if let groupId = group.id {
                    self.getInterestingPhotos(in: groupId, limit: limit).subscribe(onNext: { (photo) in
                        print("photo: \(photo.id ?? "") from group: \(groupId)")
                        observer.onNext(photo)
                    })
                        .disposed(by: self.disposeBag)
                }
                observer.onCompleted()
            }).disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
}

