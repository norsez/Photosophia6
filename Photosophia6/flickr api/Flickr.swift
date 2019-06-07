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
    
    static var invalidLogin: FlickrLogin {
        return FlickrLogin(userId: nil, userName: nil, fullName: nil)
    }
    
}

class NetworkActivityIndicator {
    static let shared = NetworkActivityIndicator()
    private init () {}
    private let serialQ = DispatchQueue(label: "serial queue network activity")
    
    func start() {
        serialQ.sync {
            DispatchQueue.main.sync {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
    
    func stop() {
        serialQ.sync {
            DispatchQueue.main.sync {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func configureIfNeeded() {
        //UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
    }
}

enum FlickrError: Error {
    case insufficientPermission
    case others
    
    static func error(_ e:Error) -> FlickrError{
        let e = e as NSError
        switch e.code {
        case 99:
            return .insufficientPermission
        default:
            return .others
        }
    }
}

//MARK: Flikr api
class Flickr{
    
    
    static let shared = Flickr()
    let api = FlickrKit.shared()
    let disposeBag = DisposeBag()
    var login: FlickrLogin?
    let PER_PAGE = 100
    
    let serialSchd = SerialDispatchQueueScheduler(internalSerialQueueName: "serial Flickr scheduler")
    let progress = PublishSubject<Float>()
    
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
                            Logger.log("json parsing error \(error)")
                            observer.onError(FlickrError.error(error))
                        }
                    }else {
                        if let error = error {
                            Logger.log("call api error: \(error)")
                            observer.onError(FlickrError.error(error))
                        }
                    }
                    
                } else if let error = error {
                    Logger.log("call response api error for \(method) \(args): \(error)")
                    observer.onError( FlickrError.error(error))
                }
            })
            return Disposables.create()
        })
    }
    
    //
    
    
    //MARK: interesting photos
    func getInterestingPhotos(in group:Group, limit: Int) -> Observable<[Photo]> {
        return Observable.create({ (observer) -> Disposable in

            var timeScope = DateComponents()
            timeScope.minute = -1
            let cal = Calendar.autoupdatingCurrent
            let qDate = cal.date(byAdding: timeScope, to: Date())

            var args: [String:Any] = ["max_upload_date": "\(qDate!.timeIntervalSince1970)",
                                      //"sort": "date-posted-desc",
                "sort": "interestingness-desc",
                                      "group_id": group.id!,
                                      "extras": "date_upload, url_sq, views, members, url_c, owner_name, description",
                                      "per_page": "\(limit)"
                                      ]
            
            do {
                if let ops = try FlickrSearchOptions.load() {
                    for e in ops.toApiOptions {
                        args[e.key] = e.value
                    }
                }
            } catch {
                Logger.log("\(error)")
            }

            self.call(method: "flickr.photos.search", args: args, topJSONKey: "photos")
                .subscribe(onNext: { (photos: Photos) in
                    
                    if let photo = photos.photo {
                        
                        let result = photo.compactMap({ (p) -> Photo in
                            var newP = p
                            newP.inGroup = group
                            return newP
                        })
                        
                        observer.onNext(result)
                    }
                    
                    observer.onCompleted()
                }, onError: {
                    error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        })
    }
    
    //groups
    
    func getAllUserGroups() -> Observable<[Group]> {
        
        return Observable.create({ (observer) -> Disposable in
            self.progress.onNext(0.1)
            self.getUserGroups(with: 0)
                .subscribe(onNext: { (firstGroups) in
                    var totalGroups = [Group]()
                    if let g = firstGroups.group {
                        totalGroups.append(contentsOf: g)
                    }
                    
                    if let totalPages = firstGroups.pages{
                        
                        var morePagesOperations = [Observable<Groups>]()
                        for page in 2...totalPages {
                            let op = self.getUserGroups(with: page)
                            morePagesOperations.append(op)
                        }
                        
                        Observable.concat(morePagesOperations)
                            .observeOn(self.serialSchd)
                            .subscribe(onNext: { (groups) in
                                if let g = groups.group {
                                    totalGroups.append(contentsOf: g)
                                }
                                self.progress.onNext(Float(groups.page ?? 0)/Float(totalPages))
                            }
                                , onError: {
                                    error in
                                    observer.onError(error)
                            }, onCompleted: {
                                observer.onNext(totalGroups)
                                observer.onCompleted()
                                self.progress.onNext(0)
                            })
                            .disposed(by: self.disposeBag)
                    }
                    
                    
                },
                           
                           onError: {
                            error in
                            observer.onError(error)
                })
                
                .disposed(by: self.disposeBag)
            
            
            
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
                }, onError: {
                    error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        })
        
        
    }
    
}
