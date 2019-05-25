//
//  TestRxBehaviors.swift
//  Photosophia6Tests
//
//  Created by norsez on 23/5/19.
//  Copyright © 2019 Bluedot. All rights reserved.
//

import XCTest
import RxSwift
class TestRxBehaviors: XCTestCase {
    let db = DisposeBag()
    let s = MainScheduler.instance
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let s1 = Observable<Int>.interval(10, scheduler: s)
        
        
        s1.subscribe(onNext: { (item) in
            print(item)
        })
        .disposed(by: self.db)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
