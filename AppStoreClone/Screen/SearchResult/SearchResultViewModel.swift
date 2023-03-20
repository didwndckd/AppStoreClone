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
    private var searchDisposeBag = DisposeBag()
    private let searchKeyword: BehaviorRelay<String>
    private let search: PublishRelay<Void>
    private let searchLoading = LoadingTracker()
    private let nextPageLoading = LoadingTracker()
    private let recommendKeywordList = BehaviorRelay<[String]>(value: [])
    private let softwareItems = BehaviorRelay<[SoftwareItem]>(value: [])
    private let mode = BehaviorRelay(value: Mode.recommendKeyword)
    
    init(parameter: Parameter) {
        self.searchKeyword = parameter.searchKeyword
        self.search = parameter.search
        self.bind()
    }
}

extension SearchResultViewModel {
    private func bind() {
        Observable.combineLatest(self.searchKeyword, LatestSearchKeywordStorage.shared.keywordListObservable)
            .map { keyword, list in
                return list.filter { $0.contains(keyword) }
            }
            .bind(to: self.recommendKeywordList)
            .disposed(by: self.disposeBag)
        
        self.search
            .withLatestFrom(self.searchKeyword)
            .bind(onNext: { [weak self] keyword in
                self?.fetchSoftwareItems(keyword: keyword)
            })
            .disposed(by: self.disposeBag)
        
        self.searchKeyword
            .map { _ in Mode.recommendKeyword }
            .bind(to: self.mode)
            .disposed(by: self.disposeBag)
        
        self.search
            .map { Mode.software }
            .bind(to: self.mode)
            .disposed(by: self.disposeBag)
    }
    
    func transform(input: Input) -> Output {
        input.selectedRecommendKeyword
            .asObservable()
            .withLatestFrom(self.recommendKeywordList) { ($0, $1) }
            .compactMap { index, list in
                return list.safety(index: index)
            }
            .bind(onNext: { [weak self] keyword in
                self?.searchKeyword.accept(keyword)
                self?.search.accept(())
            })
            .disposed(by: self.disposeBag)
        
        input.nextPage
            .asObservable()
            .withLatestFrom(self.searchLoading)
            .withLatestFrom(self.nextPageLoading) { ($0, $1) }
            .withLatestFrom(self.softwareItems) { ($0.0, $0.1, $1) }
            .withLatestFrom(self.searchKeyword) { ($0.0, $0.1, $0.2, $1) }
            .compactMap { loading, nextPageLoading, items, keyword -> (String, [SoftwareItem])? in
                guard !loading && !nextPageLoading && !items.isEmpty else { return nil }
                return (keyword, items)
            }
            .bind(onNext: { [weak self] keyword, items in
                self?.fetchSoftwareItemsForNextPage(keyword: keyword, oldItems: items)
            })
            .disposed(by: self.disposeBag)
        
        let searchLoading = self.searchLoading
            .asObservable()
            .flatMapLatest { loading in
                if loading {
                    return Observable.just(true).delay(.seconds(2), scheduler: MainScheduler.instance)
                }
                else {
                    return Observable.just(false)
                }
            }
        
        return Output(searchLoading: searchLoading.asDriver(onErrorJustReturn: false),
                      nextPageLoading: self.nextPageLoading.asDriver(),
                      reloadRecommendKeywordList: self.recommendKeywordList.asDriver().map { _ in () },
                      reloadSoftwareItems: self.softwareItems.asDriver().map { _ in () },
                      mode: self.mode.asDriver())
    }
}

// MARK: API
extension SearchResultViewModel {
    private func softwareItemsRequest(keyword: String, offset: Int) -> Observable<[SoftwareItem]> {
        let country = (Locale.current as NSLocale).countryCode ?? ""
        let lang = Locale.preferredLanguages.first ?? ""
        let term = keyword.replacingOccurrences(of: " ", with: "+")
        
        let target = APITarget.Itunes.search(country: country, media: ItunesMediaType.software.rawValue, lang: lang, term: term, offset: offset, limit: 20)
        return APIService.request(target, parsingType: ItunesSearchSoftwareResponseModel.self)
            .asObservable()
            .map { response in
                let newItems = response.results.map { item in
                    return SoftwareItem(name: item.trackCensoredName,
                                        developerName: item.artistName,
                                        screenshotUrls: item.screenshotUrls,
                                        iconUrl60: item.artworkUrl60,
                                        iconUrl100: item.artworkUrl100,
                                        iconUrl512: item.artworkUrl512,
                                        categorys: item.genres,
                                        description: item.description,
                                        releaseNotes: item.releaseNotes,
                                        userRatingCount: item.userRatingCount,
                                        averageUserRating: item.averageUserRating)
                }
                return newItems
            }
    }
    
    private func fetchSoftwareItems(keyword: String) {
        self.searchDisposeBag = DisposeBag()
        
        self.softwareItems.accept([])
        LatestSearchKeywordStorage.shared.storeKeyword(keyword)
        
        self.softwareItemsRequest(keyword: keyword, offset: 0)
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .trackLoading(self.searchLoading)
            .subscribe(
                onNext: { [weak self] items in
                    self?.softwareItems.accept(items)
                },
                onError: { error in
                    print(error.localizedDescription)
                })
            .disposed(by: self.searchDisposeBag)
    }
    
    private func fetchSoftwareItemsForNextPage(keyword: String, oldItems: [SoftwareItem]) {
        self.searchDisposeBag = DisposeBag()
        
        self.softwareItemsRequest(keyword: keyword, offset: oldItems.count)
            .trackLoading(self.nextPageLoading)
            .catchAndReturn(oldItems)
            .map { oldItems + $0 }
            .bind(to: self.softwareItems)
            .disposed(by: self.searchDisposeBag)
    }
    
}

extension SearchResultViewModel {
    var numberOfRecommendKeywordList: Int {
        return self.recommendKeywordList.value.count
    }
    
    func recommendKeyword(index: Int) -> String {
        return self.recommendKeywordList.value.safety(index: index) ?? ""
    }
    
    var numberOfSoftwareItems: Int {
        return self.softwareItems.value.count
    }
    
    func softwareItem(index: Int) -> SoftwareItem {
        return self.softwareItems.value.safety(index: index) ?? .empty
    }
}
