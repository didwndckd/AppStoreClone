//
//  LatestSearchKeywordStorable.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/22.
//

import Foundation
import RxSwift

protocol LatestSearchKeywordStorable {
    var keywordListObservable: Observable<[String]> { get }
    func storeKeyword(_ keyword: String)
}
