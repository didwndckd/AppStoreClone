//
//  APIServiceStub.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/22.
//

import Foundation
import RxSwift
import Moya

final class APIServiceStub: APIServiceable {
    var sampleData: Data?
    
    func request<T, P>(_ target: T, pluginds: [Moya.PluginType], callbackQueue: DispatchQueue, progress: ((Double) -> Void)?, parsingType: P.Type) -> RxSwift.Single<P> where T : APITargetType, P : Decodable {
        
        guard let data = self.sampleData else {
            print("t: noSampleData")
            return .error(StubError.noSampleData)
        }
        
        let provider = APIProvider<T>(
            endpointClosure: { target in
                return Endpoint(url: URL(target: target).absoluteString,
                                sampleResponseClosure: { .networkResponse(200, data)},
                                method: target.method,
                                task: target.task,
                                httpHeaderFields: target.headers)
            },
            stubClosure: MoyaProvider.immediatelyStub,
            callbackQueue: callbackQueue,
            plugins: pluginds)
            
        return provider.request(target: target, progress: { progress?($0.progress) })
            .flatMap { response -> Single<P> in
                do {
                    let result = try JSONDecoder().decode(P.self, from: response.data)
//                    print("t: api response -> \(result)")
                    return .just(result)
                }
                catch {
                    print("t: api error -> \(error)")
                    return .error(APIError.parsingFailure(originError: error, originData: response.data))
                }
            }
    }
}

extension APIServiceStub {
    enum StubError: Error {
        case noSampleData
    }
}
