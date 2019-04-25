//
//  FlickrLoginCell.swift
//  Photosophia6
//
//  Created by norsez on 23/4/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit

class FlickrLoginCell: UICollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    var actionTapLoginIn: (()->())?
    
    @IBAction func didTapLogInButton(_ sender: Any) {
        if let c = self.actionTapLoginIn {
            c()
        }
    }
}
