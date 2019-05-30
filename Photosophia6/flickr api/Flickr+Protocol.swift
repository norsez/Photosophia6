//
//  Flickr+TestData.swift
//  Photosophia6
//
//  Created by norsez on 23/5/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift


protocol FlickrApiProtocol {
    
    //MARK: auth
    func beginAuth () -> Observable<URL>
    func completeAuth(with url: URL) -> Observable<FlickrLogin>
    func checkAuth () -> Observable<FlickrLogin>
    
    
    //use cases
    func loadInterestingPhotos(withEachGroupLimitTo limit: Int) -> Observable<Photo>
    func loadPhotosophiaInterestingGroupPhotos() -> Observable<Photos>
}
