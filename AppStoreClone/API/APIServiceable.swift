//
//  APIServiceable.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/22.
//

import Foundation
import RxSwift
import Moya

protocol APIServiceable {
    func request<T: APITargetType, P: Decodable>(_ target: T,
                                                 pluginds: [PluginType],
                                                 callbackQueue: DispatchQueue,
                                                 progress: ((Double) -> Void)?,
                                                 parsingType: P.Type) -> Single<P>
    
    func request<T: APITargetType, P: Decodable>(_ target: T, parsingType: P.Type) -> Single<P>
}

extension APIServiceable {
    func request<T: APITargetType, P: Decodable>(_ target: T, parsingType: P.Type) -> Single<P> {
        return self.request(target, pluginds: [], callbackQueue: .main, progress: nil, parsingType: parsingType)
    }
}
