//
//  FlickrApiSearchOptions.swift
//  Photosophia6
//
//  Created by norsez on 4/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation

protocol Parameter {
    var parameterName: String {get}
    var parameterKey: String {get}
}
struct FlickrSearchOptions: Codable {
    
    enum DateRange: Int, CustomStringConvertible, Parameter {
        case oneDay, oneWeek, oneMonth, threeMonths, sixMonths
        static let ALL: [DateRange] = [.oneDay, .oneWeek, .oneMonth, .threeMonths, .sixMonths]
        
        var parameterName: String {
            get {
                return self.description
            }
        }
        
        var parameterKey: String {
            get {
                return "" //not used
            }
        }
        
        var description: String{
            get {
                switch self {
                case .oneDay:
                    return "1 Day"
                case .oneWeek:
                    return "1 Week"
                case .threeMonths:
                    return "3 Months"
                case .oneMonth:
                    return "1 Month"
                case .sixMonths:
                    return "6 Months"
                }
            }
        }
        
        func toDates() -> (start: Date, end: Date) {
            let TODAY = Date()
            let INTERVAL_1_DAY: TimeInterval =  60 * 60 * 24
            switch self {
            case .oneDay:
                return (start: TODAY.addingTimeInterval(-INTERVAL_1_DAY) , end: TODAY)
            case .oneWeek:
                return (start: TODAY.addingTimeInterval(-INTERVAL_1_DAY * 7) , end: TODAY)
            case .oneMonth:
                return (start: TODAY.addingTimeInterval(-INTERVAL_1_DAY * 30) , end: TODAY)
            case .threeMonths:
                return (start: TODAY.addingTimeInterval(-INTERVAL_1_DAY * 30 * 3) , end: TODAY)
            case .sixMonths:
                return (start: TODAY.addingTimeInterval(-INTERVAL_1_DAY * 30 * 6) , end: TODAY)
            }
        }
    }
    
    enum SafeSearch: Int, CustomStringConvertible, Parameter {
        case safe = 1
        case moderate = 2
        case restricted = 3
        static let ALL: [SafeSearch] = [.safe, .moderate, .restricted]
        var parameterName: String {
            get {
                return "Safe Search"
            }
        }
        var parameterKey: String {
            get {
                return "safe_search"
            }
        }
        var description: String{
            get {
                switch self {
                case .safe:
                    return "Safe"
                case .moderate:
                    return "Moderate"
                case .restricted:
                    return "Restricted"
                }
            }
        }
    }
    
    var safeSearch: SafeSearch = .safe
    //var groupId: String? = nil
    var dateRange: DateRange = .oneWeek
    
    init() {
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case safeSearch
        case dateRange
        case groupId
    }
    
    init(from decoder: Decoder) throws {
        
        let con = try decoder.container(keyedBy: CodingKeys.self)

        //self.groupId = try con.decode(String.self, forKey: .groupId)
        
        let _safeSearch = try con.decode(Int.self, forKey: .safeSearch)
        self.safeSearch = SafeSearch(rawValue: _safeSearch) ?? .safe
        
        let _dateRange = try con.decode(Int.self, forKey: .dateRange)
        self.dateRange = DateRange(rawValue: _dateRange) ?? .oneWeek
    }
    
    func encode(to encoder: Encoder) throws {
        var con = encoder.container(keyedBy: CodingKeys.self)
//        if let g = groupId {
//          try con.encode(g, forKey: .groupId)
//        }
        try con.encode(self.dateRange.rawValue, forKey: .dateRange)
        try con.encode(self.safeSearch.rawValue, forKey: .safeSearch)
    }
    
    var toApiOptions: [String:Any] {
        get {
            var result = [String:Any]()
            result["safe_search"] = "\(self.safeSearch.rawValue)"
            let range = self.dateRange.toDates()
            result["max_upload_date"] = "\(Int(range.end.timeIntervalSince1970))"
            result["min_upload_date"] = "\(Int(range.start.timeIntervalSince1970))"
//            if let g = self.groupId {
//                result["group_id"] = g
//            }
            return result
        }
    }
}
//MARK:
extension FlickrSearchOptions {
    static let PREF_KEY = "FlickrSearchOptions"
    static func save (options: FlickrSearchOptions, with completion: (()->())?) throws {
        let data = try JSONEncoder().encode(options)
        let dataString = String(data: data, encoding: .utf8)
        let df = UserDefaults.standard
        df.set(dataString, forKey: FlickrSearchOptions.PREF_KEY)
        df.synchronize()
    }
    
    static func load() throws -> FlickrSearchOptions?  {
        let df = UserDefaults.standard
        let string = df.string(forKey: FlickrSearchOptions.PREF_KEY)
        if let data = string?.data(using: .utf8) {
            let result = try JSONDecoder().decode(FlickrSearchOptions.self, from: data)
            return result
        }
        
        let defaultOptions = FlickrSearchOptions()
        return defaultOptions
    }
}
