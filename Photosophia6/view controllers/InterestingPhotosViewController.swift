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
    
    enum Section: Int {
        case loginButton = 0
        case photos = 1
        static let COUNT = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = .blackTranslucent
        self.view.backgroundColor = self.collectionView.backgroundColor
        
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
            self.showPhoto(from: indexPath)
        }
    }
    
    func showFlickrAuthFlow() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let ctrl = sb.instantiateViewController(withIdentifier: "auth webview") as! AuthWebViewController
        self.present(ctrl, animated: true, completion: nil)
    }
    
    //MARK: Rx
    func createCallbacks() {
        
        self.viewModel.photos
            .subscribe(onNext: { (photos) in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.loginViewModel.showLoginSection
            .skip(1)
            .subscribe(onNext: { (showing) in
                self.collectionView.reloadData()
            })
        .disposed(by: self.disposeBag)
    }
    
    func bindViewToViewModel() {
        //collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
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
  
}
