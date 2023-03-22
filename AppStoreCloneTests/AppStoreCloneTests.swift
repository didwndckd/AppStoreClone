//
//  AppStoreCloneTests.swift
//  AppStoreCloneTests
//
//  Created by yjc_mac on 2023/03/18.
//

import XCTest
@testable import AppStoreClone
import RxSwift

final class AppStoreCloneTests: XCTestCase {

    override func setUpWithError() throws {
        print(#function)
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // 여기에 설정 코드를 입력합니다. 이 메서드는 클래스의 각 테스트 메서드를 호출하기 전에 호출됩니다.
    }

    override func tearDownWithError() throws {
        print(#function)
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // 여기에 분해 코드를 입력합니다. 이 메서드는 클래스의 각 테스트 메서드 호출 후에 호출됩니다.
    }
    
    private let disposeBag = DisposeBag()

    func testExample() throws {
        print(#function)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // 이것은 기능 테스트 사례의 예입니다.
        // XCTAssert 및 관련 함수를 사용하여 테스트가 올바른 결과를 생성하는지 확인합니다.
        // XCTest에 대해 작성하는 모든 테스트는 throws 및 async로 주석을 달 수 있습니다.
        // 테스트에서 잡히지 않은 오류가 발생할 때 예기치 않은 실패를 생성하도록 테스트 throw를 표시합니다.
        // 비동기 코드가 완료될 때까지 기다릴 수 있도록 테스트를 비동기로 표시합니다. 나중에 어설션으로 결과를 확인하십시오.
    }

    func testPerformanceExample() throws {
        print(#function)
        // This is an example of a performance test case.
        // 이것은 성능 테스트 사례의 예입니다.
        self.measure {
            print(#function)
            // Put the code you want to measure the time of here.
            // 여기에 시간을 측정하고 싶은 코드를 넣는다.
        }
    }

}
