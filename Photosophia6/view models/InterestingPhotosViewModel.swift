//
//  InterestingPhotosViewModel.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxSwift
import RxCocoa

class LogInterestPhotosViewModel {
    
    func loadSamplePhotos () {
        
    }
    
    func loadInterestingPhotos() {
        
    }
    
    func select(photo: Photo){
        
    }
    
    func share(photo: Photo) {
        
    }
    
}


class InterestingPhotoViewModel {
    var allGroups = [Group]()
    private var allPhotos = [Photo]()
    private var selectedGroups = [Group]()
    
    let loginViewModel = LoginViewModel()
    let logViewModel = LogInterestPhotosViewModel()
    let photos = BehaviorRelay<[Photo]>(value: [])
    let disposeBag = DisposeBag()
    let api = Flickr.shared
    
    let MAX_PER_GROUP = 15
    let PHOTOS_PER_PAGE = 100
    var lastGroupIndex = 0
    
    let onError = PublishSubject<String>()
    let onStatus = PublishSubject<String>()
    let serialSchd = SerialDispatchQueueScheduler(internalSerialQueueName: "interesting photo view model serial")
    
    let dateFormatter = DateFormatter()
    
    init() {
        self.initlialize()
    }
    
    func initlialize() {
         ModelService.shared.selectedGroups()
            .asSingle()
            .subscribe(onSuccess: { (groups) in
                self.selectedGroups = groups
            })
        .disposed(by: self.disposeBag)
        
        ModelService.shared.onUpdateSelectedGroups
            .subscribe(onNext: { (newSelectedGroups) in
                self.selectedGroups = newSelectedGroups
                self.updatePhotos()
            })
        .disposed(by: self.disposeBag)
    }
    
    private func updatePhotos() {
        
        if self.selectedGroups.count == 0 {
            self.photos.accept(self.allPhotos)
            return 
        }
        
        
        let visiblePhotos = self.allPhotos.filter { (p) -> Bool in
            if let g = p.inGroup {
                return self.selectedGroups.contains(where: { (sg) -> Bool in
                    return sg.nsid == g.nsid
                })
            }else {
                return false
            }
        }
        
        self.photos.accept( visiblePhotos )
    }
    
    private func loadGroups() {
        
        self.onStatus.onNext("loading groups…")
        
        self.api.getAllUserGroups()
            .observeOn(self.serialSchd)
            .subscribe(onNext: { (groups) in
            
            self.allGroups = groups.shuffled()
            if self.allGroups.count > 0 {
                self.onStatus.onNext("received \(self.allGroups.count) groups")
                self.loadPhotos()
            }
        }, onError: UIStatus.handleError,
           onCompleted: {
            () in
            self.onStatus.onNext("You have \(self.allGroups.count) groups.")
        })
            .disposed(by: self.disposeBag)
    }
   
    func loadPhotos() {
        
        
        if allGroups.count == 0 {
            self.loadGroups()
        }else {
            self.onStatus.onNext("loading photos…")
            var groupstoLoad = [Observable<[Photo]>]()
            let offset = Int(Float(self.PHOTOS_PER_PAGE) / Float(self.MAX_PER_GROUP))
            for i in lastGroupIndex..<lastGroupIndex + offset  {
                let g = self.allGroups[i]
                groupstoLoad.append(self.api.getInterestingPhotos(in: g, limit: self.MAX_PER_GROUP))
            }
            lastGroupIndex = lastGroupIndex + offset
            
            let totalGroups = groupstoLoad.count
            var loadedGroups = 0
            self.api.progress.onNext(0)
            
            Observable<[Photo]>.concat(groupstoLoad)
                .observeOn(self.serialSchd)
                .subscribe(onNext: { (photos) in
                    var existing = self.allPhotos
                    let newPhotos = photos.filter({ (p) -> Bool in
                        return !self.allPhotos.contains(where: { (aP) -> Bool in
                            return p.id == aP.id
                        })
                    })
                    existing.append(contentsOf: newPhotos)
                    self.allPhotos = existing
                    self.updatePhotos()
                    
                    loadedGroups = loadedGroups.advanced(by: 1)
                    self.api.progress.onNext(Float(loadedGroups)/Float(totalGroups-1))
                }, onError: UIStatus.handleError,
                   onCompleted: {
                    () in
                    self.onStatus.onNext("showing \(self.photos.value.count) photos.")
                })
                .disposed(by: self.disposeBag)
            
            
        }
    }
    
    func reloadPhotos() {
        self.onStatus.onNext("Reload photos…")
        self.allPhotos = []
        self.updatePhotos()
        self.loadPhotos()
    }
    
    func loadSamplePhotos() {
        self.onStatus.onNext("loading…")
        self.api.loadPhotosophiaInterestingGroupPhotos()
            .subscribe(onNext: { [weak self] (newPhotos) in
                if  let photos = newPhotos.photo {
                    self?.photos.accept(photos)
                    self?.onStatus.onNext("\(photos.count) photos")
                    self?.api.progress.onNext(0)
                }
                
            }, onError: UIStatus.handleError)
            .disposed(by: self.disposeBag)
        
    }
    
    func caption(of p: Photo) -> String {
        return "\(p.title ?? "untitled") by \(p.ownername ?? "unknown")"
    }
    
}
