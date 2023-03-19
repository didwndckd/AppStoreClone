//
//  APITarget.Itunes.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import Foundation
import Moya

extension APITarget {
    enum Itunes {
        case search(country: String, media: String?, lang: String, term: String, offset: Int, limit: Int)
    }
}

extension APITarget.Itunes: APITargetType {
    var baseURL: URL {
        return URL(string: Constants.Domain.itunes)!
    }
    
    var path: String {
        switch self {
        case .search:
            return "search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .search(country: let country, media: let media, lang: let lang, term: let term, offset: let offset, limit: let limit):
            let parameters: [String: Any] = ["country": country,
                                             "media": media ?? "all",
                                             "lang": lang,
                                             "term": term,
                                             "offset": offset,
                                             "limit": limit]
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
