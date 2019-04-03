//
//  LoginViewController.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, ViewRxProtocol {
    
    
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewToViewModel()
        self.createCallbacks()
        self.viewModel.checkLogin()
    }
    
    @IBAction func didLogInButton(_ sender: Any) {
        self.performSegue(withIdentifier: Segue.FlickrLogin.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.FlickrLogin.rawValue {
            if let ctrl = segue.destination as? AuthWebViewController {
                ctrl.authViewModel.isLoggedIn
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self](login) in
                        self?.viewModel.loginStatus.accept(login)
                    }
                        , onError: {
                            [weak self] error in
                            ctrl.dismiss(animated: true, completion: nil)
                            self?.alert(error: "\(error)")
                    })
                    .disposed(by: self.disposeBag)
                
            }
        }
    }
    
    func createCallbacks() {
        self.viewModel.loginStatus
            .observeOn(MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { (login) in
            self.performSegue(withIdentifier: Segue.InterestingPhotos.rawValue, sender: self)
        })
            .disposed(by: self.disposeBag)
    }
    
    func bindViewToViewModel() {
        
    }
}
