//
//  ScreenshotItem.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation

struct ScreenshotItem {
    let url: URL
    let width: Double
    let height: Double
}

extension ScreenshotItem {
    init?(imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return nil }
        let lastPath = url.lastPathComponent
        let filtered = lastPath.filter { $0.isNumber || $0 == "x" }
        let numbers = filtered.split(separator: "x").compactMap { Double($0) }
        guard numbers.count == 2 else { return nil }
        
        self.url = url
        self.width = numbers[0]
        self.height = numbers[1]
    }
}
