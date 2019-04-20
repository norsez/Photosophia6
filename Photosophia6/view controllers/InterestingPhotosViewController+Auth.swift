//
//  InterestingPhotosViewController+Auth.swift
//  Photosophia6
//
//  Created by norsez on 21/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
extension InterestingPhotosViewController {
    
    func confirmAuth() {
        
        let loginVM = self.viewModel.loginViewModel
        
        loginVM.checkLoginResult
            .observeOn(MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { (result) in
                switch result {
                case .loggedIn(_):
                    self.viewModel.loadPhotos()
                case .notLoggedIn:
                    self.viewModel.loginViewModel.beginAuth()
                }
            }, onError: UIErrorHandling)
        .disposed(by: self.disposeBag)
        
        loginVM.beginAuthResult
            .observeOn(MainScheduler.instance)
            .share()
            .skip(1)
            .subscribe(onNext: { (url) in
                if let url = url {
                    self.startFlickrAuth(with: url)
                }else {
                    self.alert(error: "Didn't receive flickr login url")
                }
            }, onError: UIErrorHandling,
                onCompleted: nil, onDisposed: nil)
            .disposed(by: self.disposeBag)
        
        loginVM.processAuthResult
            .observeOn(MainScheduler.instance)
            .share()
            .skip(1)
            .subscribe(onNext: { (result) in
                switch result {
                case .notLoggedIn:
                    self.alert(message: "Not logged in")
                case .loggedIn(_):
                    self.viewModel.loadPhotos()
                }
            }, onError: UIErrorHandling,
                onCompleted: nil, onDisposed: nil)
        .disposed(by: self.disposeBag)
        
        
        loginVM.checkLogin()
    }
    
    
    func startFlickrAuth(with launchUrl: URL) {
        let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auth webview") as! AuthWebViewController
        ctrl.launchURL = launchUrl
        ctrl.loginViewModel = self.viewModel.loginViewModel
        let nav = UINavigationController(rootViewController: ctrl)
        self.present(nav, animated: true, completion: nil)
    }
}
