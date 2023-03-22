//
//  LatestSearchKeywordStorageStub.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/22.
//

import Foundation
import RxRelay
import RxSwift

final class LatestSearchKeywordStorageStub: LatestSearchKeywordStorable {
    
    private let keywordList: BehaviorRelay<[String]>
    
    init(defaultKeywordList: [String]) {
        self.keywordList = .init(value: defaultKeywordList)
    }
    
    var keywordListObservable: Observable<[String]> {
        return self.keywordList.asObservable()
    }
    
    func storeKeyword(_ keyword: String) {
        guard !keyword.isEmpty else { return }
        var currentList = self.keywordList.value
        
        if let oldIndex = currentList.firstIndex(of: keyword) {
            currentList.remove(at: oldIndex)
            currentList.insert(keyword, at: 0)
        }
        else {
            currentList.insert(keyword, at: 0)
        }
        
        self.keywordList.accept(currentList)
    }
}
