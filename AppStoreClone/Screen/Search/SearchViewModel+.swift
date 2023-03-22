//
//  SearchViewModel+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

extension SearchViewModel {
    struct Input {
        let searchKeyword: Signal<String>
        let search: Signal<Void>
        let selectedLatestSearchKeyword: Signal<Int>
    }
    
    struct Output {
        let reload: Driver<[String]>
        let searchKeyword: Driver<String>
        let isSearchMode: Driver<Bool>
        let moveTo: Driver<MoveTo>
    }
    
    enum MoveTo {
        case softwareDetail(SoftwareItem)
    }
}
