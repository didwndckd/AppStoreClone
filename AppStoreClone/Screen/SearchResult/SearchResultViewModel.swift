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
    private let searchKeyword: BehaviorRelay<String>
    private let search: PublishRelay<Void>
    private let loading = LoadingTracker()
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
    private func convertResponseItemToSoftwareItem(_ item: ItunesSearchSoftwareResponseModel.Item) -> SoftwareItem {
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
            .bind(onNext: { keyword in
                LatestSearchKeywordStorage.shared.storeKeyword(keyword)
                self.softwareItems.accept([])
                self.searchApps(offset: 0, limit: 20)
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
        
        return Output(reloadRecommendKeywordList: self.recommendKeywordList.asDriver().map { _ in () },
                      reloadSoftwareItems: self.softwareItems.asDriver().map { _ in () },
                      mode: self.mode.asDriver())
    }
}

// MARK: API
extension SearchResultViewModel {
    private func searchApps(offset: Int, limit: Int) {
        let country = (Locale.current as NSLocale).countryCode ?? ""
        let lang = Locale.preferredLanguages.first ?? ""
        let term = self.searchKeyword.value.replacingOccurrences(of: " ", with: "+")
        
        let target = APITarget.Itunes.search(country: country, media: ItunesMediaType.software.rawValue, lang: lang, term: term, offset: offset, limit: limit)
        APIService.request(target, parsingType: ItunesSearchSoftwareResponseModel.self)
            .trackLoading(self.loading)
            .subscribe(
                onNext: { [weak self] response in
                    let newItems = response.results.compactMap { item in
                        return self?.convertResponseItemToSoftwareItem(item)
                    }
                    
                    let oldItems = self?.softwareItems.value ?? []
                    self?.softwareItems.accept(oldItems + newItems)
                },
                onError: { error in
                    print(error.localizedDescription)
                })
            .disposed(by: self.disposeBag)
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
