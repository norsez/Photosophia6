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
class AuthWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet var webView: WKWebView!
    let disposeBag = DisposeBag()
    var loginViewModel: LoginViewModel!
    var launchURL: URL?
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
    @IBOutlet var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
        
        if loginViewModel == nil {
            fatalError("set loginViewModel before viewDidLoad()")
        }
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if let url = launchURL{
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        
        self.loginViewModel.processAuthResult
            .observeOn(MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { (result) in
                self.dismissSelf()
            }, onError: UIErrorHandling,
               onCompleted: nil, onDisposed: nil)
        .disposed(by: self.disposeBag)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.progress = Float(webView.estimatedProgress)
        }
        
        self.progressView.isHidden = self.progressView.progress == 0 || self.progressView.progress == 1
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            self.loginViewModel.processAuth(url: url)
        }else {
            Logger.log("no url to process")
        }
        decisionHandler(.allow)
   
    }
    
}
