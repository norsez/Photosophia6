//
//  Group+Codable.swift
//  Photosophia6
//
//  Created by norsez on 1/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation

class Group: Codable, CustomStringConvertible {
    let admin: Int?
    let iconFarm: Int?
    let iconServer: Int?
    let id: String?
    let member: Int?
    let memberCount: String?
    let moderator: Int?
    let nsid: String?
    let name: String?
    let poolCount: String?
    let photoCount: String?
    let privacy: String?
    let topicCount: String?
    
    private enum CodingKeys: String, CodingKey {
        case admin
        case iconFarm
        case iconServer
        case id
        case member
        case memberCount = "member_count"
        case moderator
        case nsid
        case name
        case poolCount = "pool_count"
        case photoCount = "photos"
        case privacy
        case topicCount = "topic_count"
        
    }
    
    var description: String{
        get {
            return "group: \(name ?? "unnamed") \(id ?? "-")"
        }
    }
}

struct Groups: Codable, CustomStringConvertible {
    let page: Int?
    let pages: Int?
    let perPage: Int?
    let total: Int?
    let group: [Group]?
    
    private enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case group
    }
    
    var description: String {
        get{
            return "\(group?.count ?? 0) groups, \(page ?? 0)/\(pages ?? 0)"
        }
    }
}

