//
//  ElasticDocAddResponse.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 14.07.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation

struct ElasticDocAddResponse: Codable {
    let _index: String
    // let _type: String
    let _id: String
    let _version: Int
    let result: String
}
