//
//  InterestingPhotosViewController+Analytics.swift
//  Photosophia6
//
//  Created by norsez on 1/6/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import UIKit

extension InterestingPhotosViewController {
    func logLoadSampleGroups() {
        Analytics.shared.log(event: Analytics.Event.loadSamplePhotos)
    }
    
    func logLoadPhotos() {
        Analytics.shared.log(event: Analytics.Event.loadPhotos)
    }
    
    func logSelect(photo: Photo) {
        Analytics.shared.log(event: Analytics.Event.selectPhoto, group: photo.inGroup, photo: photo)
    }
    
    func logShare(photo: Photo) {
        Analytics.shared.log(event: Analytics.Event.sharePhoto, group: photo.inGroup, photo: photo)
    }
}
