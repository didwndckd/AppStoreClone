//
//  SearchTests.swift
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

final class SearchTests: XCTestCase {
    
    private let disposeBag = DisposeBag()
    private let scheduler = TestScheduler(initialClock: 0)
    private let storage = LatestSearchKeywordStorageStub(defaultKeywordList: [])
    private let searchKeyword = PublishRelay<String>()
    private let search = PublishRelay<Void>()
    private let selectedLatestSearchKeyword = PublishRelay<Int>()
    private var viewModel: SearchViewModel!
    private var output: SearchViewModel.Output!
    
    override func setUp() {
        self.viewModel = SearchViewModel(latestKeywordStorage: self.storage)
        let input = SearchViewModel.Input(searchKeyword: self.searchKeyword.asSignal(),
                                          search: self.search.asSignal(),
                                          selectedLatestSearchKeyword: self.selectedLatestSearchKeyword.asSignal())
        self.output = self.viewModel.transform(input: input)
    }
    
    func testReload() {
        self.scheduler.createColdObservable([
            .next(10, "카카오"),
            .next(20, "카카오뱅크")
        ])
        .bind(onNext: { [weak self] keyword in
            self?.searchKeyword.accept(keyword)
            self?.search.accept(())
        })
        .disposed(by: self.disposeBag)
        
        expect(self.output.reload)
            .events(scheduler: self.scheduler, disposeBag: self.disposeBag)
            .to(equal([
                .next(0, []),
                .next(10, ["카카오"]),
                .next(20, ["카카오뱅크", "카카오"]),
            ]))
        
    }
    
    func testSearchKeyword() {
        self.scheduler.createColdObservable([
            .next(10, "카카오"),
            .next(20, "카카오뱅크")
        ])
        .bind(onNext: { [weak self] keyword in
            self?.searchKeyword.accept(keyword)
            self?.search.accept(())
        })
        .disposed(by: self.disposeBag)
        
        expect(self.output.searchKeyword)
            .events(scheduler: self.scheduler, disposeBag: self.disposeBag)
            .to(equal([
                .next(0, ""),
                .next(10, "카카오"),
                .next(20, "카카오뱅크")
            ]))
    }
    
    func testIsSearchMode() {
        self.scheduler.createColdObservable([
            .next(10, "카카오"),
            .next(20, "카카오뱅크"),
            .next(30, ""),
        ])
        .bind(onNext: { [weak self] keyword in
            self?.searchKeyword.accept(keyword)
            self?.search.accept(())
        })
        .disposed(by: self.disposeBag)
        
        expect(self.output.isSearchMode)
            .events(scheduler: self.scheduler, disposeBag: self.disposeBag)
            .to(equal([
                .next(0, false),
                .next(10, true),
                .next(30, false)
            ]))
    }
    
    func testMoveTo() {
        self.scheduler.createColdObservable([
            .next(10, SoftwareItem.empty),
            .next(20, SoftwareItem.empty)
        ])
        .bind(onNext: { [weak self] item in
            self?.viewModel.searchResultViewModel.selectedSoftwareItem?(item)
        })
        .disposed(by: self.disposeBag)
        
        let moveToItem = self.output.moveTo
            .map { moveTo in
                switch moveTo {
                case .softwareDetail(let item):
                    return item
                }
            }
        expect(moveToItem)
            .events(scheduler: self.scheduler, disposeBag: disposeBag)
            .to(equal([
                .next(10, .empty),
                .next(20, .empty)
            ]))
    }
    
}
 
