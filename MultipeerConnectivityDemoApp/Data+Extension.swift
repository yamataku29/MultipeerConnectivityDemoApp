//
//  Data+Extension.swift
//  MultipeerConnectivityDemoApp
//
//  Created by Taku Yamada on 2021/05/11.
//

import Foundation

extension Data {
    var string: String? {
        String(data: self, encoding: .utf8)
    }
}
