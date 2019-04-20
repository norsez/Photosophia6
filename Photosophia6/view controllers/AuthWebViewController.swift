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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
