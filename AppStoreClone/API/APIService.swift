//
//  APIService.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import Moya

final class APIService: APIServiceable {
    func request<T: APITargetType, P: Decodable>(_ target: T,
                                                 pluginds: [PluginType],
                                                 callbackQueue: DispatchQueue,
                                                 progress: ((Double) -> Void)?,
                                                 parsingType: P.Type) -> Single<P> {
        return APIProvider<T>(plugins: pluginds).request(target: target, callbackQueue: callbackQueue, progress: { progress?($0.progress) })
            .flatMap { response -> Single<P> in
                do {
                    let result = try JSONDecoder().decode(P.self, from: response.data)
                    return .just(result)
                }
                catch {
                    return .error(APIError.parsingFailure(originError: error, originData: response.data))
                }
            }
    }
}
