//
//  ViewController.swift
//  Photosophia6
//
//  Created by norsez on 31/3/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//
//        Flickr.shared.checkAuth().subscribe(onNext: { (cred) in
//            Flickr.shared.getAllUserGroups()
//                .subscribe(onNext: { (g) in
//                    print(g)
//                })
//                .disposed(by: self.disposeBag)
//        })
//            .disposed(by: self.disposeBag)
        
//        Flickr.shared.getInterestingPhotos(in: "609782@N25").subscribe(onNext: { (photo) in
//            print(photo)
//        }).disposed(by: self.disposeBag)
        
//        AuthStatusViewModel.performAuthIfNeeded(with: self, completion: {
//            login in
//            self.alert(message: login.description)
//        })
        
        Flickr.shared.checkAuth().subscribe(onNext: { (login) in
            Flickr.shared.loadInterestingPhotos(withEachGroupLimitTo: 2).subscribe(onNext: { (p) in
                
            })
            .disposed(by: self.disposeBag)
        })
        .disposed(by: self.disposeBag)
        
        
    }


}

