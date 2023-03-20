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
    
    init(softwareItem: SoftwareItem) {
        self.softwareItem = .init(value: softwareItem)
    }
}

extension SoftwareDetailViewModel {
    func transform(input: Input) -> Output {
        return Output()
    }
}
