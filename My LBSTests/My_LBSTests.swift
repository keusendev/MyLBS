//
//  My_LBSTests.swift
//  My LBSTests
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 22.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import XCTest
@testable import My_LBS

class My_LBSTests: XCTestCase {

    // MARK: AppSettingsModel Struct Test
    func testAppSettingsMode() {
        // todo
        let settings = MyLbsConfig(host: "bls.keusen.me", username: "alain", password: "1234")
        assert(settings.host == "bls.keusen.me")
        assert(settings.username == "alain")
        assert(settings.password == "1234")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData = try! jsonEncoder.encode(settings)
        print(jsonData)
        
        
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
