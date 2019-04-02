//
//  AuthStatusViewModel.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class AuthStatusViewModel {
    
    let api = Flickr.shared
    
    let disposeBag = DisposeBag()
    
    var isLoggedIn = BehaviorRelay<FlickrLogin>(value: FlickrLogin(userId: nil, userName: nil, fullName: nil))
    var onErrorMessage = BehaviorRelay<String?>(value: nil)
    
    var onRequestFlickrAuthToken = BehaviorRelay<()>(value:())
    var onRequestCompleteAuth = BehaviorRelay<()>(value:())
    
    //MARK: auth flow
    func processAuth(url: URL?) {
        guard let url = url else {
            self.onErrorMessage.accept("Exit. URL can't be nil.")
            return
        }
        
        if url.scheme!.hasPrefix("http") && (url.query ?? "") .contains("oauth_token") {
            self.onRequestFlickrAuthToken.accept(())
        }else if url.scheme == "photosophia" && (url.query ?? "") .contains("oauth_token") {
            Flickr.shared.completeAuth(with: url)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (credentials) in
                    print(credentials)
                    self.isLoggedIn.accept(credentials)
                })
                .disposed(by: self.disposeBag)
            
        }
    }
    
    static let classDisposeBag = DisposeBag()
    static func performAuthIfNeeded(with vc: UIViewController, completion: @escaping (FlickrLogin)->Void ) {
        
        Flickr.shared.checkAuth().subscribe(onNext: { (result) in
            completion(result)
            
        }, onError: { (error) in
            print(error)
            Flickr.shared.beginAuth()
                
                .subscribe(onNext: { (url) in
                    let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auth webview") as! AuthWebViewController
                    ctrl.launchURL = url
                    let nav = UINavigationController(rootViewController: ctrl)
                    vc.present(nav, animated: true, completion: nil)
                    
                }).disposed(by: classDisposeBag)
            
        })
        .disposed(by: classDisposeBag)
        
    }
    
}
