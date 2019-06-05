//
//  OptionsViewModel.swift
//  Photosophia6
//
//  Created by norsez on 5/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift

class SearchOptionsViewModel {
    
    enum OptionType {
        case multipleChoices
    }
    
    enum OptionItem: Int {
        case dateRange, safeSearch
        static let ALL: [OptionItem] = [.dateRange, .safeSearch]
        var displayLabel : String {
            get {
                switch self {
                case .dateRange:
                    return "Interval"
                case .safeSearch:
                    return "Safe Search"
                }
            }
        }
        
        var multipleChoices: [String] {
            get{
                switch self {
                case .dateRange:
                    return FlickrSearchOptions.DateRange.ALL.compactMap({ (d) -> String? in
                        return d.parameterName
                    })
                case .safeSearch:
                    return FlickrSearchOptions.SafeSearch.ALL.compactMap({ (d) -> String? in
                        return d.parameterName
                    })
                }
            }
        }
    }
    
    let onStatus = PublishSubject<String>()
    let onError = PublishSubject<String>()
    let onOptionsDidSave = PublishSubject<()>()
    var options = Variable<FlickrSearchOptions>(FlickrSearchOptions())
    
    func displayValue(at optionIndex: OptionItem) -> String{
        switch optionIndex {
        case .dateRange:
            return self.options.value.dateRange.parameterName
        case .safeSearch:
            return self.options.value.safeSearch.parameterName
        }
    }
    
    func optionType(at index: Int) -> [OptionType] {
        return [OptionType.multipleChoices, OptionType.multipleChoices]
    }
    
    
    
    func selectChoice(for optionIndex:OptionItem, at index: Int) {
        var o = self.options.value
        switch optionIndex {
        case .dateRange:
            o.dateRange = FlickrSearchOptions.DateRange.ALL[index]
        case .safeSearch:
            o.safeSearch = FlickrSearchOptions.SafeSearch.ALL[index]
        }
        self.options.value = o
    }
    
    func saveOptions() {
        do {
            try FlickrSearchOptions.save(options: self.options.value) {
                self.onStatus.onNext("Options saved.")
                self.onOptionsDidSave.onNext(())
            }
        } catch {
            self.onError.onNext("\(error)")
        }
    }
    
}
