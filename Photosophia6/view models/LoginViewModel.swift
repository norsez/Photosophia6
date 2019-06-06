//
//  loginViewModel.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum FlickrLoginResult {
    case notLoggedIn
    case loggedIn(String)
}

/*
 
 LM = LoginViewModel
 AWV = AuthWebViewController
 VC = some viewController
 
 VC ->> LM: |call checkLogIn()|
 LM ->> LM: |post flickrLogin status|
 
 alt is not logged in
 VC ->> LM: |subscribe to beginAuth url result|
 VC ->>  LM: |call Flickr.beginAuth()|
 LM ->> LM: |post login url|
 VC ->> AWV: |launch AWV with login url |
 
 AWV ->> LM: |subscribe to processAuth(with:url) result|
 AWV ->> LM: |call processAuth(with:url)|
 LM ->> LM: |post login result|
 AWV ->> AWV: |dismiss self after getting result|
 
 else is logged in
 VC ->> VC: |go on about its business|
 end
 
 
 */

class LoginViewModel {
    let api = Flickr.shared
    let disposeBag = DisposeBag()
    let checkLoginResult = PublishSubject<FlickrLoginResult>()
    let beginAuthResult = PublishSubject<URL>()
    let processAuthResult = PublishSubject<FlickrLoginResult>()
    let onErrorMessage = PublishSubject<String>()
    let showLoginSection = BehaviorRelay<Bool>(value: false)
    
    func checkLogin() {
        
        self.api.checkAuth()
            .map({ (login) -> FlickrLoginResult in
                if let userId = login.userId {
                    return FlickrLoginResult.loggedIn(userId)
                }else {
                    return FlickrLoginResult.notLoggedIn
                }
            })
            .debug()
            .subscribe(onNext: { (result) in
                self.checkLoginResult.onNext(result)
            },
                onError: {
                        error in
                        self.checkLoginResult.onNext(.notLoggedIn)
            },
                       onCompleted: nil, onDisposed: nil)
            .disposed(by: self.disposeBag)
        
//        UIStatus.needsLogin.subscribe(onNext: { (_) in
//            self.showLoginSection.accept(true)
//        })
//            .disposed(by: self.disposeBag)
    }
    
    func beginAuth() {
        self.api.beginAuth().subscribe(onNext: { (url) in
            self.beginAuthResult.onNext(url)
        }, onError: { (error) in
            self.onErrorMessage.onNext("\(error)")
        }, onCompleted: nil, onDisposed: nil)
        .disposed(by: self.disposeBag)
    }
    
    func processAuth(url: URL) {
        
        if url.scheme!.hasPrefix("http") && (url.query ?? "") .contains("oauth_token") {
          Logger.log("url: \(url)")
        }else if url.scheme == "photosophia" && (url.query ?? "") .contains("oauth_token") {
            
            self.api.completeAuth(with: url)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (credentials) in
                    Logger.log("\(credentials)")
                    let result = credentials.userId != nil ? FlickrLoginResult.loggedIn(credentials.userId!) : FlickrLoginResult.notLoggedIn
                    self.processAuthResult.onNext(result)
                })
                .disposed(by: self.disposeBag)
            
        }
    }
}
