//
//  SoftwareDetailViewModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation
import RxSwift
import RxCocoa

final class SoftwareDetailViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let softwareItem: BehaviorRelay<SoftwareItem>
    private let rows = BehaviorRelay<[RowType]>(value: [])
    
    init(softwareItem: SoftwareItem) {
        self.softwareItem = .init(value: softwareItem)
        self.bind()
    }
}

extension SoftwareDetailViewModel {
    private func bind() {
        self.softwareItem
            .map { item -> [RowType] in
                let headerItem = HeaderItem(iconImageURL: item.iconUrl512,
                                            name: item.name,
                                            category: item.categorys.first ?? "",
                                            userRatingCount: item.userRatingCount,
                                            averageUserRating: item.averageUserRating,
                                            ageText: item.trackContentRating,
                                            developer: item.developerName,
                                            languageCode: item.languageCode ?? "",
                                            languageCount: item.languageCodes.count)
                
                let newFeatureItem = NewFeatureItem(version: item.version,
                                                    releaseNotes: item.releaseNotes,
                                                    releaseDate: item.releaseDate)
                
                let previewItem = PreviewItem(screenshotUrls: item.screenshotUrls)
                
                let descriptionItem = DescriptionItem(description: item.description, developerName: item.developerName)
                
                return [.header(headerItem), .newFeature(newFeatureItem), .preview(previewItem), .description(descriptionItem), .spacing(1000)]
            }
            .bind(to: self.rows)
            .disposed(by: self.disposeBag)
    }
    
    func transform(input: Input) -> Output {
        
        return Output(smallIconUrl: self.softwareItem.asDriver().map { $0.iconUrl60 },
                      reload: self.rows.asDriver().map { _ in () })
    }
}

extension SoftwareDetailViewModel {
    var numberOfRows: Int {
        return self.rows.value.count
    }
    
    func row(index: Int) -> RowType {
        return self.rows.value.safety(index: index) ?? .spacing(0)
    }
}
