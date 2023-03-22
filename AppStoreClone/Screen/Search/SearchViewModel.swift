//
//  SearchViewModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: BaseViewModel, ViewModel {
    private let disposeBag = DisposeBag()
    private let latestKeywordStorage: LatestSearchKeywordStorable
    let searchResultViewModel: SearchResultViewModel
    
    private let searchKeyword: BehaviorRelay<String>
    private let search: PublishRelay<Void>
    private let latestKeywordList = BehaviorRelay<[String]>(value: [])
    private let moveTo = PublishRelay<MoveTo?>()
    
    init(latestKeywordStorage: LatestSearchKeywordStorable = LatestSearchKeywordStorage()) {
        self.latestKeywordStorage = latestKeywordStorage
        let searchKeyword = BehaviorRelay(value: "")
        let search = PublishRelay<Void>()
        let parameter = SearchResultViewModel.Parameter(searchKeyword: searchKeyword.asObservable(), search: search.asObservable())
        self.searchKeyword = searchKeyword
        self.search = search
        self.searchResultViewModel = SearchResultViewModel(parameter: parameter, latestKeywordStorage: latestKeywordStorage)
        
        super.init()
        self.setupSearchResultViewModel()
        self.bind()
    }
    
    private func setupSearchResultViewModel() {
        self.searchResultViewModel.selectedRecommendKeyword = { [weak self] keyword in
            self?.searchKeyword.accept(keyword)
            self?.search.accept(())
        }
        
        self.searchResultViewModel.selectedSoftwareItem = { [weak self] item in
            self?.moveTo.accept(.softwareDetail(item))
        }
    }
}

extension SearchViewModel {
    private func bind() {
        self.latestKeywordStorage.keywordListObservable
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
        
        return Output(reload: self.latestKeywordList.asDriver(),
                      searchKeyword: self.searchKeyword.asDriver(),
                      isSearchMode: self.searchKeyword.asDriver().map { !$0.isEmpty }.distinctUntilChanged(),
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
}
