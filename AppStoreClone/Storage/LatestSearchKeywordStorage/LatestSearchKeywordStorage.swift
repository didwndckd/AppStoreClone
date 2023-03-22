//
//  LatestSearchKeywordService.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import Foundation
import RealmSwift
import RxSwift
import RxRelay

final class LatestSearchKeywordStorage {
    static let shared = LatestSearchKeywordStorage()
    init() {
        self.fetchItems()
    }
    
    private let realm = try? Realm(configuration: Realm.Configuration(schemaVersion: Constants.Realm.schemaVersion))
    private let items = BehaviorRelay<Results<LatestSearchKeywordStoreItem>?>(value: nil)
}

extension LatestSearchKeywordStorage {
    private func getItems() -> Results<LatestSearchKeywordStoreItem>? {
        return self.realm?.objects(LatestSearchKeywordStoreItem.self)
    }
    
    private func appendItem(keyword: String) {
        let lastId = self.getItems()?.last?.id ?? -1
        let id = lastId + 1
        let item = LatestSearchKeywordStoreItem(id: id, keyword: keyword, date: Date())
        do {
            try self.realm?.write {
                self.realm?.add(item)
            }
        }
        catch {
            print(#function, "error -> \(error.localizedDescription)")
        }
    }
    
    private func updateItem(_ item: LatestSearchKeywordStoreItem) {
        do {
            try self.realm?.write {
                item.date = Date()
            }
        }
        catch {
            print(#function, "error -> \(error.localizedDescription)")
        }
    }
    
    private func fetchItems() {
        let results = self.getItems()?.sorted(by: \.date, ascending: false)
        self.items.accept(results)
    }
}

// MARK: Interface
extension LatestSearchKeywordStorage: LatestSearchKeywordStorable {
    var keywordListObservable: Observable<[String]> {
        return self.items
            .map { items -> [LatestSearchKeywordStoreItem] in
                guard let items = items else { return [] }
                return Array(items)
            }
            .map { items in
                return items.map { $0.keyword }
            }
            .asObservable()
    }
    
    func storeKeyword(_ keyword: String) {
        guard !keyword.isEmpty else { return }
        
        if let oldItem = self.items.value?.first(where: { $0.keyword == keyword }) {
            self.updateItem(oldItem)
        }
        else {
            self.appendItem(keyword: keyword)
        }
        
        self.fetchItems()
    }
}
