//
//  GroupSelectViewController.swift
//  Photosophia6
//
//  Created by norsez on 8/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GroupSelectViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
   
    
    let CELLID = "CELLID"
    let viewModel = GroupSelectViewModel()
    var searchController: UISearchController?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDone))
        //self.navigationItem.rightBarButtonItem = doneButton
        
        self.viewModel.onUpdateSelectionIndex
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] (indices) in
                let indexPaths = indices.compactMap({ (idx) -> IndexPath? in
                    return IndexPath(item: idx, section: 0)
                })
                self?.tableView.reloadRows(at: indexPaths, with: .automatic)
            })
            .disposed(by: self.disposeBag)
        
        
        
        
        
        self.searchController = UISearchController(searchResultsController: self)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.searchBar.autocapitalizationType = .none
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        self.searchController?.delegate = self
        self.searchController?.searchBar.delegate = self
        self.definesPresentationContext = true
        
        let searchBar = self.searchController?.searchBar
//        let results = searchBar!.rx.text.orEmpty
//            .throttle(0.5, scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
//            .flatMapLatest { query -> Observable<[Group]> in
//                if query.isEmpty {
//                    return .just([])
//                }
//                let matchedGroups = self.viewModel.allGroups.value.filter({ (g) -> Bool in
//                    return (g.name ?? "").contains(query)
//                })
//                return .just(matchedGroups)
//            }
//            .observeOn(MainScheduler.instance)
//        
//        results
//            .bind(to: tableView.rx.items(cellIdentifier: "CELLID",
//                                         cellType: UITableViewCell.self)) {
//                                            [weak self]
//                                            (index, group: Group, cell) in
//                                            self?.setup(cell: cell, group: group)
//            }
//            .disposed(by: disposeBag)
        
        self.viewModel.initialize() {
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.allGroups.value.count
    }
    
    func setup(cell: UITableViewCell, group: Group) {
        cell.textLabel?.text = group.name ?? "Untitled"
        cell.accessoryType = self.viewModel.isSelected(group) ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELLID, for: indexPath)
        
        let group = self.viewModel.allGroups.value[indexPath.row]
        self.setup(cell: cell, group: group)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.viewModel.toggleSelection(at: indexPath.row)
        
    }
    //
    //    @objc func didPressDone() {
    //        self.viewModel.doneSelection()
    //    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.doneSelection()
    }
    
    
    //MARK: search
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
