//
//  SearchResultViewModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchResultViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let searchKeyword: Observable<String>
    private let search: Observable<Void>
    
    init(parameter: Parameter) {
        self.searchKeyword = parameter.searchKeyword
        self.search = parameter.search
    }
}

extension SearchResultViewModel {
    struct Parameter {
        let searchKeyword: Observable<String>
        let search: Observable<Void>
    }
    struct Input {}
    struct Output {}
}

extension SearchResultViewModel {
    func transform(input: Input) -> Output {
        return Output()
    }
}
