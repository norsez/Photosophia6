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
    private var groups = [Group]()
    
    let loginViewModel = LoginViewModel()
    let logViewModel = LogInterestPhotosViewModel()
    let photos = BehaviorRelay<[Photo]>(value: [])
    let disposeBag = DisposeBag()
    let api = Flickr.shared
    
    let MAX_PER_GROUP = 5
    let PHOTOS_PER_PAGE = 100
    var lastGroupIndex = 0
    
    let onError = PublishSubject<String>()
    let onStatus = PublishSubject<String>()
    let serialSchd = SerialDispatchQueueScheduler(internalSerialQueueName: "interesting photo view model serial")
    
    let dateFormatter = DateFormatter()
    
    
    private func loadGroups() {
        
        self.onStatus.onNext("loading groups…")
        
        self.api.getAllUserGroups()
            .observeOn(self.serialSchd)
            .subscribe(onNext: { (groups) in
            
            self.groups = groups.shuffled()
            if self.groups.count > 0 {
                self.onStatus.onNext("received \(self.groups.count) groups")
                self.loadPhotos()
            }
        }, onError: UIStatus.handleError,
           onCompleted: {
            () in
            self.onStatus.onNext("You have \(self.groups.count) groups.")
        })
            .disposed(by: self.disposeBag)
    }
   
    func loadPhotos() {
        
        
        if groups.count == 0 {
            self.loadGroups()
        }else {
            self.onStatus.onNext("loading photos…")
            var groupstoLoad = [Observable<[Photo]>]()
            let offset = Int(Float(self.PHOTOS_PER_PAGE) / Float(self.MAX_PER_GROUP))
            for i in lastGroupIndex..<lastGroupIndex + offset  {
                let g = self.groups[i]
                groupstoLoad.append(self.api.getInterestingPhotos(in: g, limit: self.MAX_PER_GROUP))
            }
            lastGroupIndex = lastGroupIndex + offset
            
            let totalGroups = groupstoLoad.count
            var loadedGroups = 0
            self.api.progress.onNext(0)
            
            Observable<[Photo]>.concat(groupstoLoad)
                .observeOn(self.serialSchd)
                .subscribe(onNext: { (photos) in
                    var existing = self.photos.value
                    let newPhotos = photos.filter({ (p) -> Bool in
                        return !self.photos.value.contains(where: { (aP) -> Bool in
                            return p.id == aP.id
                        })
                    })
                    existing.append(contentsOf: newPhotos)
                    self.photos.accept(existing)
                    
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
        self.photos.accept([])
        self.loadPhotos()
    }
    
    func loadSamplePhotos() {
        self.onStatus.onNext("loading…")
        self.api.loadPhotosophiaInterestingGroupPhotos()
            .subscribe(onNext: { [weak self] (newPhotos) in
                if let _self = self,
                    let photos = newPhotos.photo {
                    _self.photos.accept(photos)
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
