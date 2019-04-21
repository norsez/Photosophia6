//
//  Flickr.swift
//  Photosophia6
//
//  Created by norsez on 31/3/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import FlickrKit

struct FlickrLogin: CustomStringConvertible {
    let userId: String?
    let userName: String?
    let fullName: String?
    
    var description: String {
        get {
            return "\(userId ?? "not logged in.") (\(self.userName ?? ""))"
        }
    }
    
}

//MARK: Flikr api
class Flickr {
    
    enum ApiError: Error {
        case responseError(String)
    }
    
    static let shared = Flickr()
    let api = FlickrKit.shared()
    let disposeBag = DisposeBag()
    var login: FlickrLogin?
    let PER_PAGE = 100
    private init() {
        self.api.initialize(withAPIKey: FlickrKeys.flickr_key.rawValue,
                                      sharedSecret: FlickrKeys.flickr_secret.rawValue)
        self.api.checkAuthorization { (userName, userId, userFullname, error) in
            Logger.log("init Flickr api. \( userId ?? "<not yet logged in.>" )")
        }
    }
    
    //the main api call method
    func call<T: Decodable>(method: String, args: [String:Any], topJSONKey: String ) -> Observable<T> {
        return Observable.create({ (observer) -> Disposable in
            self.api.call(method, args: args, maxCacheAge: .oneHour, completion: { (response, error) in
                if let res = response {
                    
                    let responseJSON = JSON(res)
                    if responseJSON["stat"].stringValue == "ok",
                        let firstLevel = res[topJSONKey] {
                        let decoder = JSONDecoder()
                        do {
                            let data = try JSONSerialization.data(withJSONObject: firstLevel, options: [])
                            let result = try decoder.decode(T.self, from: data)
                            observer.onNext(result)
                            observer.onCompleted()
                        } catch {
                            print(error)
                            observer.onError(error)
                        }
                    }else {
                        let error: Error = ApiError.responseError("call api call")
                        observer.onError(error)
                    }
                    
                } else if let error = error {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        })
    }
    
    //
    
    
    //MARK: interesting photos
    func getInterestingPhotos(in group_id: String, limit: Int) -> Observable<Photo> {
        return Observable.create({ (observer) -> Disposable in

            var timeScope = DateComponents()
            timeScope.minute = -1
            let cal = Calendar.autoupdatingCurrent
            let qDate = cal.date(byAdding: timeScope, to: Date())

            let args: [String:Any] = ["max_upload_date": "\(qDate!.timeIntervalSince1970)",
                                      "sort": "date-posted-desc",
                                      "group_id": group_id,
                                      "extras": "date_upload, url_sq, views, members, url_c, owner_name, description",
                                      "per_page": "\(limit)"
                                      ]

            self.call(method: "flickr.photos.search", args: args, topJSONKey: "photos")
                .subscribe(onNext: { (photos: Photos) in
                    photos.photo?.forEach({ (p) in
                        observer.onNext(p)
                    })
                    
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        })
    }
    
    //groups
    
    func getAllUserGroups() -> Observable<Group> {
        
        return Observable.create({ (observer) -> Disposable in
            let kickoff = self.getUserGroups(with: 0)
                .subscribe(onNext: { (firstGroups) in
                    
                    //emits first group's resutls
                    firstGroups.group?.shuffled().forEach({ (g) in
                        observer.onNext(g)
                    })
                    
                    
                    if let totalPages = firstGroups.pages{
                        
                        
                        var morePagesOperations = [Observable<Groups>]()
                        for page in 2...totalPages {
                            let op = self.getUserGroups(with: page)
                            morePagesOperations.append(op)
                        }
                        
                        Observable.concat(morePagesOperations)
                            .subscribe(onNext: { (groups) in
                                groups.group?.shuffled().forEach({ (g) in
                                    observer.onNext(g)
                                })
                            })
                            .disposed(by: self.disposeBag)
                    }
                    
                    observer.onCompleted()
                })
            
            kickoff.disposed(by: self.disposeBag)
            return Disposables.create()
        })
        
    }
    
    func getUserGroups(with page: Int) -> Observable<Groups> {
        return Observable.create({ (observer) -> Disposable in
            
            self.call(method: "flickr.groups.pools.getGroups",
                      args: ["page_page": "\(self.PER_PAGE)", "page": "\(page)"],
                      topJSONKey: "groups")
                .subscribe(onNext: { (groups: Groups) in
                    print("number of groups: \(groups.group?.count ?? 0) for page \(page)")
                    observer.onNext(groups)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        })
        
        
    }
    
}
