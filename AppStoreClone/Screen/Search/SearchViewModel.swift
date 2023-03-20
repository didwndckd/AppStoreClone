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
    private let latestKeywordList = BehaviorRelay<[String]>(value: [])
    private let moveTo = PublishRelay<MoveTo?>()
    
    init() {
        self.bind()
    }
}

extension SearchViewModel {
    private func bind() {
        LatestSearchKeywordStorage.shared.keywordListObservable
            .bind(to: self.latestKeywordList)
            .disposed(by: self.disposeBag)
    }
    
    func transform(input: Input) -> Output {
        input.searchKeyword
            .asObservable()
            .bind(to: self.searchKeyword)
            .disposed(by: self.disposeBag)
        
        input.search
            .asObservable()
            .bind(to: self.search)
            .disposed(by: self.disposeBag)
        
        input.selectedLatestSearchKeyword
            .asObservable()
            .withLatestFrom(self.latestKeywordList) { ($0, $1) }
            .compactMap { index, list in
                return list.safety(index: index)
            }
            .bind(onNext: { [weak self] keyword in
                self?.searchKeyword.accept(keyword)
                self?.search.accept(())
            })
            .disposed(by: self.disposeBag)
        
        return Output(reload: self.latestKeywordList.asDriver().map { _ in () },
                      searchKeyword: self.searchKeyword.asDriver(),
                      isSearchMode: self.searchKeyword.asDriver().map { !$0.isEmpty },
                      moveTo: self.moveTo.asDriver(onErrorJustReturn: nil).compactMap { $0 })
    }
}

extension SearchViewModel {
    var numberOfLatestKeywords: Int {
        return self.latestKeywordList.value.count
    }
    
    func latestKeyword(index: Int) -> String {
        return self.latestKeywordList.value.safety(index: index) ?? ""
    }
    
    var searchResultViewModel: SearchResultViewModel {
        let parameter = SearchResultViewModel.Parameter(searchKeyword: self.searchKeyword.asObservable(),
                                                        search: self.search.asObservable())
        
        let viewModel = SearchResultViewModel(parameter: parameter)
        
        viewModel.selectedRecommendKeyword = { [weak self] keyword in
            self?.searchKeyword.accept(keyword)
            self?.search.accept(())
        }
        
        viewModel.selectedSoftwareItem = { [weak self] item in
            self?.moveTo.accept(.softwareDetail(item))
        }
        return viewModel
    }
}
