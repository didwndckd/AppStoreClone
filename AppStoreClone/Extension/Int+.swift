//
//  Int+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/20.
//

import Foundation

extension Int {
    func toSimpleCountText() -> String {
        let doubleValue = Double(self)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        
        if doubleValue > 10000 {
            let value = doubleValue / 10000
            let stringValue = formatter.string(from: value as NSNumber) ?? String(value)
            return stringValue + "만"
        }
        else if doubleValue > 1000 {
            let value = doubleValue / 1000
            let stringValue = formatter.string(from: value as NSNumber) ?? String(value)
            return stringValue + "천"
        }
        else {
            return String(self)
        }
    }
}
