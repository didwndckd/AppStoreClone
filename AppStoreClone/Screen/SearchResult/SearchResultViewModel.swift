//
//  SearchResultViewModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchResultViewModel: BaseViewModel, ViewModel {
    private let disposeBag = DisposeBag()
    private var searchDisposeBag = DisposeBag()
    private let searchKeyword: Observable<String>
    private let search: Observable<Void>
    var selectedRecommendKeyword: ((String) -> Void)?
    var selectedSoftwareItem: ((SoftwareItem) -> Void)?
    
    private let haveNextPage = BehaviorRelay(value: false)
    private let searchLoading = LoadingTracker()
    private let nextPageLoading = LoadingTracker()
    private let recommendKeywordList = BehaviorRelay<[String]>(value: [])
    private let softwareItems = BehaviorRelay<[SoftwareItem]>(value: [])
    private let mode = BehaviorRelay(value: Mode.recommendKeyword)
    private let latestKeywordStorage: LatestSearchKeywordStorable
    private let apiService: APIServiceable
    
    init(parameter: Parameter, latestKeywordStorage: LatestSearchKeywordStorable, apiService: APIServiceable = APIService()) {
        self.searchKeyword = parameter.searchKeyword
        self.search = parameter.search
        self.latestKeywordStorage = latestKeywordStorage
        self.apiService = apiService
        super.init()
        self.bind()
    }
}

extension SearchResultViewModel {
    private func bind() {
        Observable.combineLatest(self.searchKeyword, self.latestKeywordStorage.keywordListObservable)
            .map { keyword, list in
                return list.filter { $0.contains(keyword) }
            }
            .distinctUntilChanged()
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
                self?.selectedRecommendKeyword?(keyword)
            })
            .disposed(by: self.disposeBag)
        
        input.selectedSoftware
            .asObservable()
            .withLatestFrom(self.softwareItems) { ($0, $1) }
            .compactMap { index, items in
                return items.safety(index: index)
            }
            .bind(onNext: { [weak self] item in
                self?.selectedSoftwareItem?(item)
            })
            .disposed(by: self.disposeBag)
        
        input.nextPage
            .asObservable()
            .withLatestFrom(self.searchLoading)
            .withLatestFrom(self.nextPageLoading) { ($0, $1) }
            .withLatestFrom(self.softwareItems) { ($0.0, $0.1, $1) }
            .withLatestFrom(self.searchKeyword) { ($0.0, $0.1, $0.2, $1) }
            .withLatestFrom(self.haveNextPage) { ($0.0, $0.1, $0.2, $0.3, $1) }
            .compactMap { loading, nextPageLoading, items, keyword, haveNextPage -> (String, [SoftwareItem])? in
                guard !loading && !nextPageLoading && haveNextPage else { return nil }
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
                      reloadRecommendKeywordList: self.recommendKeywordList.asDriver(),
                      reloadSoftwareItems: self.softwareItems.asDriver(),
                      mode: self.mode.asDriver())
    }
}

// MARK: API
extension SearchResultViewModel {
    func softwareItemsRequest(keyword: String, offset: Int) -> Observable<[SoftwareItem]> {
        let country = (Locale.current as NSLocale).countryCode ?? ""
        let lang = Locale.preferredLanguages.first ?? ""
        let term = keyword.replacingOccurrences(of: " ", with: "+")
        
        let target = APITarget.Itunes.search(country: country,
                                             media: ItunesMediaType.software.rawValue,
                                             lang: lang,
                                             term: term,
                                             offset: offset,
                                             limit: 20)
        
        return self.apiService.request(target, parsingType: ItunesSearchSoftwareResponseModel.self)
            .asObservable()
            .map { response in
                let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
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
                                        averageUserRating: item.averageUserRating,
                                        trackContentRating: item.trackContentRating,
                                        languageCodes: item.languageCodesISO2A,
                                        version: item.version,
                                        releaseDate: item.releaseDate.toDate(format: dateFormat, timeZone: TimeZone(identifier: "GMT")),
                                        currentVersionReleaseDate: item.currentVersionReleaseDate.toDate(format: dateFormat, timeZone: TimeZone(identifier: "GMT")))
                }
                return newItems
            }
    }
    
    private func fetchSoftwareItems(keyword: String) {
        self.searchDisposeBag = DisposeBag()
        self.softwareItems.accept([])
        self.latestKeywordStorage.storeKeyword(keyword)
        self.softwareItemsRequest(keyword: keyword, offset: 0)
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .trackLoading(self.searchLoading)
            .catchAndReturn([])
            .bind(onNext: { [weak self] items in
                self?.softwareItems.accept(items)
                self?.haveNextPage.accept(!items.isEmpty)
            })
            .disposed(by: self.searchDisposeBag)
    }
    
    private func fetchSoftwareItemsForNextPage(keyword: String, oldItems: [SoftwareItem]) {
        self.searchDisposeBag = DisposeBag()
        
        self.softwareItemsRequest(keyword: keyword, offset: oldItems.count)
            .trackLoading(self.nextPageLoading)
            .catchAndReturn([])
            .bind(onNext: { [weak self] items in
                self?.softwareItems.accept(oldItems + items)
                self?.haveNextPage.accept(!items.isEmpty)
            })
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
