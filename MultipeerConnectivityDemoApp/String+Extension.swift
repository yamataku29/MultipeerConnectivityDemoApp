//
//  String+Extension.swift
//  MultipeerConnectivityDemoApp
//
//  Created by Taku Yamada on 2021/05/11.
//

import Foundation

extension String {
    var data: Data? {
        data(using: .utf8)
    }
}
