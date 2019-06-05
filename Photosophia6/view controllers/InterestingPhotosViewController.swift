//
//  InterestingPhotosViewController.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import Kingfisher


class InterestingPhotosViewController: UICollectionViewController, ViewRxProtocol, UICollectionViewDelegateFlowLayout {
   
    let viewModel = InterestingPhotoViewModel()
    let disposeBag = DisposeBag()
    let CELL_ID_PHOTO = "thumbnail cell"
    let CELL_LOGIN = "flickr login cell"
    
    let serialScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "serial scheduler")
    var selectedPhotoIndex: Int? 
    
    enum Section: Int {
        case loginButton = 0
        case photos = 1
        static let COUNT = 2
    }
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var lightboxLabel: UILabel!
    @IBOutlet var lightboxCaptionView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = .blackTranslucent
        self.view.backgroundColor = self.collectionView.backgroundColor
        if let navBar = self.navigationController?.navigationBar {
            self.progressView.frame = CGRect(x: 0, y: navBar.bounds.height - 2, width: navBar.bounds.width, height: 2)
            self.progressView.alpha = 0.7
            navBar.addSubview(self.progressView)
        }
        
        self.createCallbacks()
        self.bindViewToViewModel()
        
        self.confirmAuth()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.COUNT
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case Section.loginButton.rawValue:
            return self.viewModel.loginViewModel.showLoginSection.value ? 1 : 0
        default:
            return self.viewModel.photos.value.count
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = Section(rawValue: indexPath.section)!
        let CELL_ID: String
        switch section {
        case .loginButton:
            CELL_ID = self.CELL_LOGIN
        default:
            CELL_ID = self.CELL_ID_PHOTO
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath)
        
        switch section {
        case .loginButton:
            let lcell = cell as! FlickrLoginCell
            lcell.actionTapLoginIn = {
                self.viewModel.loginViewModel.beginAuth()
            }
        default:
            let tcell = cell as! ThumbnailCell
            if let photoUrl = self.viewModel.photos.value[indexPath.row].photoURL(with:.th100) {
                tcell.imageView.kf.setImage(with: photoUrl, options: [.transition(.fade(0.2))] )
            }
        }
        
        
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section  = Section(rawValue: indexPath.section)!
        if section == .photos {
            let photo = self.viewModel.photos.value[indexPath.row]
            self.showPhoto(from: indexPath)
            self.logSelect(photo: photo)
        }
    }
    
    func showFlickrAuthFlow() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let ctrl = sb.instantiateViewController(withIdentifier: "auth webview") as! AuthWebViewController
        self.present(ctrl, animated: true, completion: nil)
    }
    
    let threshold:CGFloat = 100.0 // threshold from bottom of tableView
    var isLoadingMore = false // flagx
    
    //MARK: Rx
    func createCallbacks() {
        
        self.collectionView.rx.didScroll
            .filter({ (e) -> Bool in
                let contentOffset =  self.collectionView.contentOffset.y
                let maximumOffset = self.collectionView.contentSize.height - self.collectionView.frame.size.height;
                return maximumOffset - contentOffset <= self.threshold
            })
            .throttle(10, latest: true, scheduler: self.serialScheduler)
            //.debounce(8, scheduler: self.serialScheduler)
            .subscribe(onNext: { (_) in
                self.viewModel.loadPhotos()
            })
            .disposed(by: self.disposeBag)
        
        
        self.viewModel.photos
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (photos) in
                    self.collectionView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.loginViewModel.showLoginSection
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (showing) in
                self.collectionView.reloadData()
            })
        .disposed(by: self.disposeBag)
        
        self.viewModel.api.progress
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (pValue) in
                self.progressView.isHidden = pValue == 0 || pValue > 1
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.onError
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (text) in
                UIStatus.showStatusError(text: text)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.onStatus
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (text) in
                UIStatus.showStatus(text: text)
            })
            .disposed(by: self.disposeBag)
        
        
        self.viewModel.loginViewModel.onErrorMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (text) in
                UIStatus.showStatusError(text: text)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func bindViewToViewModel() {
        //collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        self.viewModel.api.progress
            .bind(to: self.progressView.rx.progress)
            .disposed(by: self.disposeBag)
        
        
    
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let section = Section(rawValue: indexPath.section)!
        switch section {
        case  .loginButton:
            return CGSize(width: collectionView.frame.width, height: 120)
        default:
            let width = collectionView.bounds.width
            let cellWidth = (width - 0) / 5 // compute your cell width
            return CGSize(width: cellWidth, height: cellWidth )
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search options" {
            if let ctrl = segue.destination as? SearchOptionsViewController {
                ctrl.viewModel.onOptionsDidSave.subscribe(onNext: { [weak self] (_) in
                    self?.viewModel.reloadPhotos()
                })
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
}
