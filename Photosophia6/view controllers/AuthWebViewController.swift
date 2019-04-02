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
    var launchURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        if let url = launchURL{
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            print("no url to decide policy for.")
            return
        }
        
        if url.scheme!.hasPrefix("http") && (url.query ?? "") .contains("oauth_token") {
            decisionHandler(.allow)
        }else if url.scheme == "photosophia" && (url.query ?? "") .contains("oauth_token") {
            Flickr.shared.completeAuth(with: url)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (credentials) in
                print(credentials)
                    self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
            decisionHandler(.cancel)
        }else if url.scheme == "photosophia" {
            
            self.dismiss(animated: true) {
                let app = UIApplication.shared.delegate as! AppDelegate
                _ = app.application(UIApplication.shared, open: url, options: [:])
            }
            
            decisionHandler(.allow)
        }
        else {
            print(navigationAction.request)
            decisionHandler(.allow)
        }
    }
    
}
