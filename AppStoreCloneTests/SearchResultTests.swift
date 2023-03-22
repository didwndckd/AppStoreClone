//
//  SearchResultTests.swift
//  AppStoreCloneTests
//
//  Created by yjc on 2023/03/22.
//

import XCTest
@testable import AppStoreClone
import RxSwift
import RxCocoa
import RxTest
import Nimble
import RxNimble

final class SearchResultTests: XCTestCase {
    
    private let disposeBag = DisposeBag()
    private let scheduler = TestScheduler(initialClock: 0)
    private let apiService = APIServiceStub()
    private let keywordStorage = LatestSearchKeywordStorageStub(defaultKeywordList: ["카카오뱅크"])
    private let searchKeyword = PublishRelay<String>()
    private let search = PublishRelay<Void>()
    private var viewModel: SearchResultViewModel!
    private var output: SearchResultViewModel.Output!
    private let selectedRecommendKeyword = PublishRelay<Int>()
    private let selectedSoftware = PublishRelay<Int>()
    private let nextPage = PublishRelay<Void>()
    
    override func setUp() {
        self.apiService.sampleData = self.sampleResponseData
        let parameter = SearchResultViewModel.Parameter(searchKeyword: self.searchKeyword.asObservable(),
                                                        search: self.search.asObservable())
        
        self.viewModel = SearchResultViewModel(parameter: parameter,
                                               latestKeywordStorage: self.keywordStorage,
                                               apiService: self.apiService)
        
        let input = SearchResultViewModel.Input(selectedRecommendKeyword: self.selectedRecommendKeyword.asSignal(),
                                                selectedSoftware: self.selectedSoftware.asSignal(),
                                                nextPage: self.nextPage.asSignal())
        
        self.output = self.viewModel.transform(input: input)
    }
    
    func testReloadRecommendKeywordList() {
        self.scheduler.createColdObservable([
            .next(10, "카카오뱅크"),
            .next(20, "카카오")
        ])
        .bind(onNext: { [weak self] keyword in
            self?.searchKeyword.accept(keyword)
            self?.search.accept(())
        })
        .disposed(by: self.disposeBag)
        
        expect(self.output.reloadRecommendKeywordList)
            .events(scheduler: self.scheduler, disposeBag: self.disposeBag)
            .to(equal([
                .next(0, []),
                .next(10, ["카카오뱅크"]),
                .next(20, ["카카오", "카카오뱅크"])
            ]))
    }
    
    func testSoftwareItemsRequest() {
//        let request = self.viewModel.softwareItemsRequest(keyword: "카카오뱅크", offset: 0).map { $0.map { $0.name} }
//        expect(request)
//            .events(scheduler: self.scheduler, disposeBag: self.disposeBag)
//            .to(equal([
//                .next(0, []),
//                .next(0, ["카카오뱅크", "카카오톡", "카카오"])
//            ]))
    }
    
    func testMode() {
        self.scheduler.createColdObservable([
            .next(10, ""),
            .next(20, "카카오뱅크")
        ])
        .bind(onNext: { [weak self] keyword in
            if keyword.isEmpty {
                self?.search.accept(())
            }
            else {
                self?.searchKeyword.accept(keyword)
            }
        })
        .disposed(by: self.disposeBag)
        
        expect(self.output.mode)
            .events(scheduler: self.scheduler, disposeBag: self.disposeBag)
            .to(equal([
                .next(0, .recommendKeyword),
                .next(10, .software),
                .next(20, .recommendKeyword)
            ]))
    }
}

extension SearchResultTests {
    var sampleResponseData: Data? {
        let responseString = """
        {
         "resultCount":20,
         "results": [
            {"trackCensoredName": "카카오뱅크"},
            {"trackCensoredName": "카카오톡"},
            {"trackCensoredName": "카카오페이"}
        ]
        }
        """
        return responseString.data(using: .utf8)
    }
}
