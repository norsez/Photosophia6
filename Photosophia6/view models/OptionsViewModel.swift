//
//  OptionsViewModel.swift
//  Photosophia6
//
//  Created by norsez on 5/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchOptionsViewModel {
    
    enum OptionType {
        case multipleChoices
    }
    
    enum OptionItem: Int {
        case dateRange, safeSearch, sort
        static let ALL: [OptionItem] = [.dateRange, .safeSearch, .sort]
        var displayLabel : String {
            get {
                switch self {
                case .dateRange:
                    return "Interval"
                case .safeSearch:
                    return "Safe Search"
                case .sort:
                    return "Sorting"
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
                case .sort:
                    return FlickrSearchOptions.Sorting.ALL.compactMap({ (s) -> String? in
                        return s.parameterName
                    })
                }
            }
        }
    }
    
    let onStatus = PublishSubject<String>()
    let onError = PublishSubject<String>()
    let onOptionsDidSave = PublishSubject<()>()
    var options = BehaviorRelay<FlickrSearchOptions>(value: FlickrSearchOptions())
    
    func displayValue(at optionIndex: OptionItem) -> String{
        switch optionIndex {
        case .dateRange:
            return self.options.value.dateRange.parameterName
        case .safeSearch:
            return self.options.value.safeSearch.parameterName
        case .sort:
            return self.options.value.sort.parameterName
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
        case .sort:
            o.sort = FlickrSearchOptions.Sorting.ALL[index]
        }
        self.options.accept(o)
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
