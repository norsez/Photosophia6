//
//  PhotoSearchModel.swift
//  Photosophia6
//
//  Created by norsez on 3/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation

enum SearchSettings: String {
    case maxPhotosPerGroup
    case safeSearchOnly
    case excludedGroups
    
    static func registerDefaults() {
        let df = UserDefaults.standard
        df.register(defaults: [SearchSettings.maxPhotosPerGroup.rawValue : 5,
                               SearchSettings.safeSearchOnly.rawValue: true,
                               SearchSettings.excludedGroups.rawValue: [String]()
                               ])
        df.synchronize()
    }
    
    static func addExcluded(groupId: String) {
        let df = UserDefaults.standard
        var groupIds = df.object(forKey: SearchSettings.excludedGroups.rawValue) as! [String]
        groupIds.append(groupId)
        df.set(groupIds, forKey: SearchSettings.excludedGroups.rawValue)
        df.synchronize()
    }
    
    static func excludedGroupIds() -> [String]{
        return UserDefaults.standard.value(forKey: SearchSettings.excludedGroups.rawValue) as! [String]
    }
}
