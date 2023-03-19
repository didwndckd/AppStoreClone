//
//  LatestSearchKeywordStoreItem.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import Foundation
import RealmSwift
final class LatestSearchKeywordStoreItem: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var keyword: String
    @Persisted var date: Date
    
    convenience init(id: Int, keyword: String, date: Date) {
        self.init()
        self.id = id
        self.keyword = keyword
        self.date = date
    }
}
