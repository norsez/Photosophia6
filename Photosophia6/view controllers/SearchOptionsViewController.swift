//
//  SearchOptionsViewController.swift
//  Photosophia6
//
//  Created by norsez on 5/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: option selector
class ChoicesViewController: UITableViewController {
    let items = BehaviorRelay<[String]>(value:[])
    let selectedValue = PublishSubject<Int>()
    
    let CELLID = "CELLID"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.CELLID)
        if cell == nil {
          cell = UITableViewCell(style: .default, reuseIdentifier: self.CELLID)
        }
        cell?.textLabel?.text = self.items.value[indexPath.row]
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedValue.onNext(indexPath.row)
    }
}

//MARK: SearchOptionsViewController
class SearchOptionsViewController: UITableViewController {
    
    let viewModel = SearchOptionsViewModel()
    let CELLID = "CELLID"
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            if let options = try FlickrSearchOptions.load() {
                self.viewModel.options.accept(options)
                self.tableView.reloadData()
            }
        } catch {
            self.viewModel.onError.onNext("\(error.localizedDescription)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchOptionsViewModel.OptionItem.ALL.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELLID, for: indexPath)
        
        if let option = SearchOptionsViewModel.OptionItem(rawValue: indexPath.row) {
            let displayValue = self.viewModel.displayValue(at: option)
            cell.textLabel?.text = option.displayLabel
            cell.detailTextLabel?.text = displayValue
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let option = SearchOptionsViewModel.OptionItem(rawValue: indexPath.row) {
            let ctrl  = ChoicesViewController(style: .plain)
            ctrl.items.accept(option.multipleChoices)
            ctrl.selectedValue.subscribe(onNext: { [weak self] (index) in
                
                self?.viewModel.selectChoice(for: option, at: index)
                self?.navigationController?.popViewController(animated: true)
                self?.tableView.reloadData()
                
            })
            .disposed(by: self.disposeBag)
            
            self.navigationController?.pushViewController(ctrl, animated: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.saveOptions()
    }
    
    
}
