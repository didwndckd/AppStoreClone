//
//  SoftwareDetailViewModel+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation
import RxSwift
import RxCocoa

extension SoftwareDetailViewModel {
    struct Input {}
    
    struct Output {
        let smallIconUrl: Driver<String>
        let reload: Driver<Void>
    }
    
    final class HeaderItem {
        let iconImageURL: String
        let name: String
        let category: String
        let userRatingCount: Int
        let averageUserRating: Double
        let ageText: String
        let developer: String
        let languageCode: String
        let languageCount: Int
        var isHiddenMode: Bool
        
        init(iconImageURL: String, name: String, category: String, userRatingCount: Int, averageUserRating: Double, ageText: String, developer: String, languageCode: String, languageCount: Int, isHiddenMode: Bool = false) {
            self.iconImageURL = iconImageURL
            self.name = name
            self.category = category
            self.userRatingCount = userRatingCount
            self.averageUserRating = averageUserRating
            self.ageText = ageText
            self.developer = developer
            self.languageCode = languageCode
            self.languageCount = languageCount
            self.isHiddenMode = isHiddenMode
        }
    }
    
    final class NewFeatureItem {
        let version: String
        let releaseNotes: String
        let releaseDate: Date?
        var isFold: Bool
        
        init(version: String, releaseNotes: String, releaseDate: Date?, isFold: Bool = true) {
            self.version = version
            self.releaseNotes = releaseNotes
            self.releaseDate = releaseDate
            self.isFold = isFold
        }
    }
    
    final class PreviewItem {
        let screenshotItems: [ScreenshotItem]
        var currentIndex: Int
        
        init(screenshotItems: [ScreenshotItem], currentIndex: Int = 0) {
            self.screenshotItems = screenshotItems
            self.currentIndex = currentIndex
        }
    }
    
    final class DescriptionItem {
        let description: String
        let developerName: String
        var isFold: Bool
        
        init(description: String, developerName: String, isFold: Bool = true) {
            self.description = description
            self.developerName = developerName
            self.isFold = isFold
        }
    }
    
    
    enum RowType {
        case header(HeaderItem)
        case newFeature(NewFeatureItem)
        case preview(PreviewItem)
        case description(DescriptionItem)
        case spacing(Double)
    }
}
