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
    }
    
    struct Output {
        let reload: Driver<Void>
    }
}
