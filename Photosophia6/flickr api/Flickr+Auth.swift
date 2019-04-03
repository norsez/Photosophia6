//
//  Flickr+Auth.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import FlickrKit



//MARK: authentication
extension Flickr {
    
    func beginAuth () -> Observable<URL> {
        
        return Observable.create({ (observer) -> Disposable in
            let url = URL(string: FlickrKeys.flickr_callbackUrl.rawValue)!
            FlickrKit.shared().beginAuth(withCallbackURL: url, permission: FKPermission.write) { (url, error) in
                if let error = error {
                    observer.onError(error)
                }else if let url = url {
                    observer.onNext(url)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    func completeAuth(with url: URL) -> Observable<FlickrLogin> {
        return Observable.create({ (observer) -> Disposable in
            
            FlickrKit.shared().completeAuth(with: url, completion: { (userName, userId, userFullname, error) in
                if let error = error {
                    observer.onError(error)
                }else {
                    observer.onNext(FlickrLogin(userId: userId, userName: userName, fullName: userFullname))
                    self.login = FlickrLogin(userId: userId, userName: userName, fullName: userFullname)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        })
    }
    
    func checkAuth () -> Observable<FlickrLogin> {
        return Observable.create({ (observer) -> Disposable in
            
            FlickrKit.shared().checkAuthorization(onCompletion: { (userName, userId, userFullname, error) in
                if let error = error {
                    observer.onError(error)
                }else {
                    observer.onNext(FlickrLogin(userId: userId, userName: userName, fullName: userFullname))
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        })
    }
    
    
    
}
