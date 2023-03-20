//
//  SoftwareItem.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/20.
//

import Foundation

struct SoftwareItem {
    let name: String
    let developerName: String
    let screenshotUrls: [String]
    let iconUrl60: String
    let iconUrl100: String
    let iconUrl512: String
    let categorys: [String]
    let description: String
    let releaseNotes: String
    let userRatingCount: Int
    let averageUserRating: Double
}

extension SoftwareItem {
    static var empty: SoftwareItem {
        return SoftwareItem(name: "",
                            developerName: "",
                            screenshotUrls: [],
                            iconUrl60: "",
                            iconUrl100: "",
                            iconUrl512: "",
                            categorys: [],
                            description: "",
                            releaseNotes: "",
                            userRatingCount: 0,
                            averageUserRating: 0)
    }
    
    var screenShotImageHeightMultiPlier: Double {
        guard let url = URL(string: self.screenshotUrls.first ?? "") else { return 0 }
        let lastPath = url.lastPathComponent
        let filtered = lastPath.filter { $0.isNumber || $0 == "x" }
        let numbers = filtered.split(separator: "x").compactMap { Double($0) }
        guard numbers.count == 2 else { return 0 }
        return numbers[1] / numbers[0]
    }
}
