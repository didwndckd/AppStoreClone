//
//  String+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation

extension String {
    func toDate(format: String, timeZone: TimeZone? = nil) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }
}
