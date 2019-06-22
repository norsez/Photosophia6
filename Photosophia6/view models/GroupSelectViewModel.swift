//
//  GroupSelectViewModel.swift
//  Photosophia6
//
//  Created by norsez on 8/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: view model
class GroupSelectViewModel {
    
    let allGroups = BehaviorRelay<[Group]>(value: [])
    let selectedGroups = BehaviorRelay<[Group]>(value: [])
    
    let onSelected = PublishSubject<[Group]>()
    let onUpdateSelectionIndex = PublishSubject<[Int]>()
    
    
    let onError = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    func initialize(with completion: @escaping ()->()) {
        ModelService.shared.selectedGroups()
            .asSingle()
            .subscribe(onSuccess: { (groups) in
                if groups.count > 0 {
                    self.selectedGroups.accept(groups)
                }else {
                    self.selectedGroups.accept(self.allGroups.value)
                }
                completion()
            }, onError: UIStatus.handleError)
        .disposed(by: self.disposeBag)
    }
    
    func isSelected(_ group: Group) -> Bool {

        let selected = self.selectedGroups.value.contains(where: { (g) -> Bool in
            return g.nsid == group.nsid
        })
        return selected
    }
    
    
    func toggleSelection(at index:Int) {
        
        let group = self.allGroups.value[index]
        
        if self.isSelected(group) {
            var v = self.selectedGroups.value
            v.removeAll { (g) -> Bool in
                return g.nsid == group.nsid
            }
            self.selectedGroups.accept(v)
        }else {
            var v = self.selectedGroups.value
            v.append(group)
            self.selectedGroups.accept(v)
        }
        
        self.onUpdateSelectionIndex.onNext([index])
        
    }
    
    
    func doneSelection() {
        let results = self.selectedGroups.value.count == 0 ? self.allGroups.value : self.selectedGroups.value
        self.onSelected.onNext(results)
        ModelService.shared.saveSelected(groups: results)
            .subscribe(onNext: { () in
                Logger.log("ok")
            }, onError: { (error) in
                Logger.log("\(error)")
            })
            .disposed(by: self.disposeBag)
    }
    
    
}
