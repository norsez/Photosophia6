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
        
        let doIt = UIBarButtonItem(title: "do it", style: .done, target: self, action: #selector(test))
        self.navigationItem.rightBarButtonItem = doIt
        
        
    }
    
    @objc func test() {
        Observable.repeatElement(testOnce(), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (obs) in
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func testOnce () -> Observable<Void> {
        return Observable.create({ (obs) -> Disposable in
            
            self.longProcess()
            obs.onNext(())
            obs.onCompleted()
            
            return Disposables.create()
        })
    }
    
    func longProcess() {
        for i in 0..<1000 {
            print("\(i)")
        }
    }


}


