//
//  ErrorMapperTests.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 27/08/2024.
//

import XCTest
@testable import Network_UnitTest

final class ErrorMapperTests: XCTestCase {

    var sut: ErrorMapper!
    var dummyUrl: URL!
    let dummyError = NetworkError.general
    
    override func setUp() {
        super.setUp()
        dummyUrl = URL(string: "www.dummy.com")!
        sut = ErrorMapper()
    }
    
    override func tearDown() {
        dummyUrl = nil
        sut = nil
        super.tearDown()
    }
    
    func test_mapCalled_ThrowNetworkConnectionErrorIfNetworkHasIssue() {
        // Given
        let isNetworkReachable: Bool = false
        let dummyError = NetworkError.general
        // When
        let error = sut.map(error: dummyError, isNetworkReachable: isNetworkReachable)
        
        // Then
        XCTAssertEqual(error as? NetworkError, NetworkError.networkConnectionError)
    }
    
    
    func test_mapCalled_ThrowUnauthorizedErrorIfStatusCodeIs401() {
        // Given
        let isNetworkReachable: Bool = true
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: 401,
                                       httpVersion: nil,
                                       headerFields: nil)
        
        // When
        let error = sut.map(
            error: dummyError,
            response: response,
            isNetworkReachable: isNetworkReachable
        )
        
        // Then
        XCTAssertEqual(error as? NetworkError, NetworkError.unauthorized)
    }

    func test_mapCalled_ThrowForbiddenErrorIfStatusCodeIs403() {
        // Given
        let isNetworkReachable: Bool = true
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: 403,
                                       httpVersion: nil,
                                       headerFields: nil)
        // When
        let error = sut.map(
            error: dummyError,
            response: response,
            isNetworkReachable: isNetworkReachable
        )
        
        // Then
        XCTAssertEqual(error as? NetworkError, NetworkError.forbidden)
    }
    
    func test_mapCalled_ThrowNotFoundErrorIfStatusCodeIs404() {
        // Given
        let isNetworkReachable: Bool = true
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: 404,
                                       httpVersion: nil,
                                       headerFields: nil)
        // When
        let error = sut.map(
            error: dummyError,
            response: response,
            isNetworkReachable: isNetworkReachable
        )
        
        // Then
        XCTAssertEqual(error as? NetworkError, NetworkError.notFound)
    }
    
    func test_mapCalled_ThrowServerErrorIfStatusCodeIs500() {
        // Given
        let isNetworkReachable: Bool = true
        let randomStatusCode: Int = Int.random(in: 500..<600)
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: randomStatusCode,
                                       httpVersion: nil,
                                       headerFields: nil)
        // When
        let error = sut.map(
            error: dummyError,
            response: response,
            isNetworkReachable: isNetworkReachable
        )
        
        // Then
        XCTAssertEqual(error as? NetworkError, NetworkError.serverError)
    }
    
    func test_mapCalled_ThrowNetworkErrorIfGivenErrorIsNotNil() {
        // Given
        let isNetworkReachable: Bool = true
        
        let error = sut.map(error: dummyError, isNetworkReachable: isNetworkReachable)
        
        // Then
        XCTAssertNotNil(error as? NetworkError)
    }
}
