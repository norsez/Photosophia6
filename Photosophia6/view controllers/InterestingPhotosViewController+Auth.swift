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
            .asDriver(onErrorJustReturn: FlickrLoginResult.notLoggedIn)
            .drive(onNext: { (result) in
                switch result {
                case .loggedIn(_):
                    self.viewModel.loadPhotos()
                    self.logLoadPhotos()
                case .notLoggedIn:
                    self.viewModel.loginViewModel.showLoginSection.accept(true)
                    self.viewModel.loadSamplePhotos()
                    self.logLoadSampleGroups()
                }
            })
        .disposed(by: self.disposeBag)
        
        loginVM.beginAuthResult
            .asDriver(onErrorJustReturn: URL(fileURLWithPath: "?"))
            .drive(onNext: { (url) in
                self.startFlickrAuth(with: url)
            })
            .disposed(by: self.disposeBag)
        
        loginVM.processAuthResult
            .asDriver(onErrorJustReturn: FlickrLoginResult.notLoggedIn)
            .drive(onNext: { (result) in
                switch result {
                case .notLoggedIn:
                    self.alert(message: "Not logged in")
                case .loggedIn(_):
                    self.viewModel.photos.accept([])
                    self.viewModel.loadPhotos()
                    self.viewModel.loginViewModel.showLoginSection.accept(false)
                    
                }
            })
        .disposed(by: self.disposeBag)
        
        loginVM.onErrorMessage
            .subscribe(onNext: { (text) in
                
            })
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
