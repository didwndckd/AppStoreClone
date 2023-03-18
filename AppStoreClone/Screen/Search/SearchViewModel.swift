//
//  SearchViewModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    private let searchKeyword = BehaviorRelay(value: "")
    private let search = PublishRelay<Void>()
    private let latestKetwordList = BehaviorRelay<[String]>(value: (0...100).map { String($0) })
}

extension SearchViewModel {
    func transform(input: Input) -> Output {
        
        input.searchKeyword
            .asObservable()
            .bind(to: self.searchKeyword)
            .disposed(by: self.disposeBag)
        
        input.search
            .asObservable()
            .bind(to: self.search)
            .disposed(by: self.disposeBag)
        
        return Output(reload: self.latestKetwordList.asDriver().map { _ in () })
    }
}

extension SearchViewModel {
    var numberOfLatestKeywords: Int {
        return self.latestKetwordList.value.count
    }
    
    func latestKeyword(index: Int) -> String {
        return self.latestKetwordList.value[index]
    }
    
    var searchResultViewModel: SearchResultViewModel {
        let parameter = SearchResultViewModel.Parameter(searchKeyword: self.searchKeyword.asObservable(),
                                                        search: self.search.asObservable())
        return SearchResultViewModel(parameter: parameter)
    }
}
