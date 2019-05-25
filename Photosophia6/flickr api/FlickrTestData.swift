//
//  FlickrTestData.swift
//  Photosophia6
//
//  Created by norsez on 23/5/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift

class FlickrTestData: FlickrApiProtocol {
    func beginAuth() -> Observable<URL> {
        Logger.log("not supported in test data")
        return Observable.never()
    }
    
    func completeAuth(with url: URL) -> Observable<FlickrLogin> {
        Logger.log("not supported in test data")
        return Observable.never()
    }
    
    func checkAuth() -> Observable<FlickrLogin> {
        return Observable.of(FlickrLogin(userId: "12345", userName: "TestData", fullName: "Test Data"))
    }
    
    func loadInterestingPhotos(withEachGroupLimitTo limit: Int) -> Observable<Photo> {
        return Observable.never()
    }
    
    func loadPhotosophiaInterestingGroupPhotos() -> Observable<Photos> {
        return Observable.never()
    }
    
    
}
