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
    private let recommendKeywordList = BehaviorRelay<[String]>(value: [])
    
    init(parameter: Parameter) {
        self.searchKeyword = parameter.searchKeyword
        self.search = parameter.search
        self.bind()
    }
}

extension SearchResultViewModel {
    private func bind() {
        self.searchKeyword
            .withLatestFrom(LatestSearchKeywordStorage.shared.keywordListObservable) { ($0, $1) }
            .map { keyword, list in
                return list.filter { $0.contains(keyword) }
            }
            .bind(to: self.recommendKeywordList)
            .disposed(by: self.disposeBag)
        
        self.search
            .withLatestFrom(self.searchKeyword)
            .bind(onNext: { keyword in
                LatestSearchKeywordStorage.shared.storeKeyword(keyword)
                self.searchApps()
            })
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
        
        return Output(reloadRecommendKeywordList: self.recommendKeywordList.asDriver().map { _ in () })
    }
}

extension SearchResultViewModel {
    private func searchApps() {
        let country = (Locale.current as NSLocale).countryCode ?? ""
        let lang = Locale.preferredLanguages.first ?? ""
        let term = self.searchKeyword.value.replacingOccurrences(of: " ", with: "+")
        
        let target = APITarget.Itunes.search(country: country, media: ItunesMediaType.software.rawValue, lang: lang, term: term, offset: 0, limit: 20)
        APIService.request(target, pluginds: [APILogPlugin()], parsingType: ItunesSearchResponseModel.self)
            .asObservable()
            .bind(onNext: { [weak self] response in
                response.results.forEach { print("\($0.trackCensoredName): 다운로드\($0.userRatingCount), 별점: \($0.averageUserRating)") }
            })
            .disposed(by: self.disposeBag)
    }
}

extension SearchResultViewModel {
    var numberOfRecommendKeywordList: Int {
        return self.recommendKeywordList.value.count
    }
    
    func recommendKeyword(index: Int) -> String {
        return self.recommendKeywordList.value[index]
    }
}
