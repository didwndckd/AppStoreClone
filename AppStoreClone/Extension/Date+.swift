//
//  Date+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
