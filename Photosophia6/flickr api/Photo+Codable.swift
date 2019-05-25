//
//  Photo+Codable.swift
//  Photosophia6
//
//  Created by norsez on 1/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
struct Photo: Codable, CustomStringConvertible {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    let isPublic: Int?
    let isFriend: Int?
    let isFamily: Int?
    let dateUpload: String?
    let views: String?
    let url_sq: String?
    let url_c: String?
    let owner_name: String?
    
    var inGroup: Group?
    var description: String {
        get {
            return "\(title ?? "?") \(id ?? "no id")"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case dateUpload = "dateupload"
        case views
        case url_sq
        case url_c
        case owner_name
        
    }
}


struct Photos: Codable, CustomStringConvertible {
    let page: Int?
    let pages: Int?
    let perPage: Int?
    let total: String?
    let photo: [Photo]?
    
    private enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
    
    var description: String {
        get{
            return "\(photo?.count ?? 0) photos, \(page ?? 0)/\(pages ?? 0)"
        }
    }
}


//MARK: photo url
extension Photo {
    
    enum Size: String {
        case sq75 = "s"
        case lsq150 = "q"
        case th100 = "t"
        case s240 = "m"
        case s320 = "n"
        case m500 = "-"
        case m640 = "z"
        case m800 = "c"
        case l1024 = "b"
        case l1600 = "h"
        case l2048 = "k"
        case original = "o"
    }
    
    func photoURL(with size: Size) -> URL? {
        return URL(string: "https://farm\(self.farm ?? 0).staticflickr.com/\(self.server ?? "0")/\(self.id ?? "0")_\(self.secret ?? "0").jpg")
    }
    
//
//    https://www.flickr.com/people/{user-id}/ - profile
//    https://www.flickr.com/photos/{user-id}/ - photostream
//    https://www.flickr.com/photos/{user-id}/{photo-id} - individual photo
//    https://www.flickr.com/photos/{user-id}/sets/ - all photosets
//    https://www.flickr.com/photos/{user-id}/sets/{photoset-id} - single photoset
    
    var ownerProfileURL: URL? {
        get {
            return URL(string: "https://www.flickr.com/people/\(self.owner ?? "0")")
        }
    }
    
    var ownerPhotoStreamURL: URL? {
        get {
            return URL(string: "https://www.flickr.com/photos/\(self.owner ?? "0")")
        }
    }
    
    var photoWebURL: URL? {
        get {
            return URL(string: "https://www.flickr.com/photos/\(self.owner ?? "0")/\(self.id ?? "0")")
        }
    }
    
    var ownerPhotoSets:URL? {
        get{
            return URL(string: "https://www.flickr.com/photos/\(self.owner ?? "0")/sets")
        }
    }
}
