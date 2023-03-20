//
//  SearchResultViewModel+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import Foundation
import RxSwift
import RxCocoa

extension SearchResultViewModel {
    struct Parameter {
        let searchKeyword: BehaviorRelay<String>
        let search: PublishRelay<Void>
    }
    struct Input {
        let selectedRecommendKeyword: Signal<Int>
        let nextPage: Signal<Void>
    }
    
    struct Output {
        let searchLoading: Driver<Bool>
        let nextPageLoading: Driver<Bool>
        let reloadRecommendKeywordList: Driver<Void>
        let reloadSoftwareItems: Driver<Void>
        let mode: Driver<Mode>
    }
    
    enum Mode {
        case recommendKeyword
        case software
    }
}
