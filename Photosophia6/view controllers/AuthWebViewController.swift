//
//  AuthWebViewController.swift
//  Photosophia6
//
//  Created by norsez on 1/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
class AuthWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, ViewRxProtocol {
    
    @IBOutlet var webView: WKWebView!
    let disposeBag = DisposeBag()
    var launchURL: URL?
    let authViewModel = AuthStatusViewModel()
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if let url = launchURL{
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        
        self.bindViewToViewModel()
        self.createCallbacks()
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        self.authViewModel.processAuth(url: navigationAction.request.url)
        decisionHandler(.allow)
   
    }
    
    //MARK: ViewRxProtocol
    func createCallbacks() {
        self.authViewModel.isLoggedIn
            .skip(1)
            .subscribe(onNext: { [weak self] (login) in
                
                if login.userId == nil {
                    self?.alert(error: "Can't login Flickr", then: {self?.dismissSelf()})
                }else {
                    self?.alert(message: "Welcome, \(login.userName ?? "") [\(login.fullName ?? "")]", then: {self?.dismissSelf()})
                }
                
            }).disposed(by: self.disposeBag)
        
    }
    
    func bindViewToViewModel() {
        //
    }
    
}
