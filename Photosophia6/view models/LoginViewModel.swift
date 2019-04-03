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

class LoginViewModel {
    let api = Flickr.shared
    let disposeBag = DisposeBag()
    let loginStatus = BehaviorRelay<FlickrLogin>(value: FlickrLogin(userId: nil, userName: nil, fullName: nil))
    
    func checkLogin() {
        
        self.api.checkAuth().subscribe(onNext: { (login) in
            self.loginStatus.accept(login)
        })
        .disposed(by: self.disposeBag)
    }
    
    
    
}
