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
    //MARK: use this method to initiate login user if needed.
    func performAuthIfNeeded(with vc: UIViewController) -> Observable<FlickrLogin> {
        return Observable.create({ (observer) -> Disposable in
            let disposeBag = DisposeBag()
            return Flickr.shared.checkAuth().subscribe(onNext: { (login) in
                if login.userId != nil {
                    observer.onNext(login)
                    observer.onCompleted()
                }else {
                    Flickr.shared.beginAuth().subscribe(onNext: { (url) in
                        let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auth webview") as! AuthWebViewController
                        ctrl.launchURL = url
                        
                        ctrl.authViewModel.isLoggedIn.asDriver().drive(onNext: { (login) in
                            observer.onNext(login)
                            observer.onCompleted()
                        }).disposed(by: disposeBag)
                        
                        let nav = UINavigationController(rootViewController: ctrl)
                        vc.present(nav, animated: true, completion: nil)
                    })
                    .disposed(by: disposeBag)
                }
            })
        })
    }
    
    static func performAuthIfNeeded(with vc: UIViewController, completion: @escaping (FlickrLogin)->Void ) {
        
        Flickr.shared.checkAuth()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (result) in
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
