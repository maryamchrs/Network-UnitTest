//
//  APIHTTPRequestMapperTests.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 26/08/2024.
//

import XCTest
@testable import Network_UnitTest

final class APIHTTPRequestMapperTests: XCTestCase {

    struct MockResponse: Codable, Equatable {
        let key: String
    }
    
    var sut: APIHTTPRequestMapper!
    var dummyUrl: URL!
    var mockObject = MockResponse(key: "Key")
    
    override func setUp() {
        super.setUp()
        dummyUrl = URL(string: "www.dummy.com")!
        sut = APIHTTPRequestMapper(jsonDecoder: JSONDecoder())
    }
    
    override func tearDown() {
        dummyUrl = nil
        sut = nil
        super.tearDown()
    }
    
    
    func test_mapCalled_shouldThrowErrorIfStatusCodeIs400() {
        //Given
        let data = Data()
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)!
        //When
        XCTAssertThrowsError(try map(data: data,
                                     response: response)) { error in
            guard let error = error as? NetworkError else {
                assertionFailure()
                return
            }
            XCTAssertEqual(error, NetworkError.notAcceptedStatusCode(400))
        }
    }
    
    func test_mapCalled_shouldThrowUnableToDecode() {
        //Given
        let data = Data()
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        //When
        XCTAssertThrowsError(try map(data: data,
                                     response: response)) { error in
            guard let error = error as? NetworkError else {
                assertionFailure()
                return
            }
            XCTAssertEqual(error, NetworkError.unableToDecode)
        }
    }
    
    func test_mapCalled_shouldReturnObject() {
        //Given
        let model = try! JSONEncoder().encode(mockObject)
        let response = HTTPURLResponse(url: dummyUrl,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        //When
        
        let result = try? map(
            data: model,
            response: response
        )
        
        XCTAssertEqual(result, mockObject)
        
    }
}

extension APIHTTPRequestMapperTests {
    func map(data: Data, response: HTTPURLResponse) throws -> MockResponse {
        try sut.map(data: data,
                    response: response)
    }
}
