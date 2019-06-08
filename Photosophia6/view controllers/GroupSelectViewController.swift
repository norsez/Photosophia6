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

class GroupSelectViewController: UITableViewController {
    let CELLID = "CELLID"
    let viewModel = GroupSelectViewModel()
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELLID, for: indexPath)
        
        let group = self.viewModel.allGroups.value[indexPath.row]
        cell.textLabel?.text = group.name ?? "Untitled"
        cell.accessoryType = self.viewModel.isSelected(group) ? .checkmark : .none
        
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
}
