//
//  ModelService.swift
//  Photosophia6
//
//  Created by norsez on 8/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
class ModelService {
    let KEY_SELECTED_GROUPS = "KEY_SELECTED_GROUPS"
    
    let onUpdateSelectedGroups = PublishSubject<[Group]>()
    
    func saveSelected(groups: [Group]) -> Observable<()>{
        return Observable.create({ (observer) -> Disposable in
            
            let toSave = groups
            let groupstoSave = Groups(page: 0, pages: 0, perPage: 0, total: 0, group: toSave)
            let enc = JSONEncoder()
            do {
                let data = try enc.encode(groupstoSave)
                let dataString = String(data: data, encoding: .utf8)
                let uf = UserDefaults.standard
                uf.set(dataString, forKey: self.KEY_SELECTED_GROUPS)
                uf.synchronize()
                
                observer.onNext(())
                observer.onCompleted()
                //notify selected groups are updated
                self.onUpdateSelectedGroups.onNext(groups)
            }catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        })
    }
    
    func selectedGroups() -> Observable<[Group]> {
        return Observable.create({ (observer) -> Disposable in
            let df = UserDefaults.standard
            if let stringData = df.string(forKey: self.KEY_SELECTED_GROUPS),
                let data = stringData.data(using: .utf8){
                do {
                    let groups = try JSONDecoder().decode(Groups.self, from: data)
                    observer.onNext(groups.group ?? [])
                    observer.onCompleted()
                }catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        })
    }
    
    
    static let shared = ModelService()
    private init() {}
}
