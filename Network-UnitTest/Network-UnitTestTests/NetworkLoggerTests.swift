//
//  NetworkLoggerTests.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 27/08/2024.
//

import XCTest
@testable import Network_UnitTest

final class NetworkLoggerTests: XCTestCase {
    
    struct MockData: Codable, Equatable {
        let key: String
    }
    
    var capturedOutput: [String]!
    var sut: NetworkLogger!
    
    override func setUp() {
        super.setUp()
        capturedOutput = []
        sut = NetworkLogger(needToShowLogs: true) { [weak self] in
            self?.capturedOutput.append($0)
        }
    }
    
    override func tearDown() {
        capturedOutput = nil
        sut = nil
        super.tearDown()
    }
    
    func test_logRequest_shouldNotPrintWhenNeedToShowLogsIsFalse() {
        
        // Given
        let request = createDummyURLRequest()
        sut.changeLogsVisibilityStatus(false)
        
        // When
        sut.logRequest(request)
        
        // Then
        XCTAssertTrue(capturedOutput.isEmpty)
    }
    
    func testLogRequest_WhenNeedToShowLogsIsTrue_ShouldPrintLogs() {
        // Given
        let request = createDummyURLRequest()
        sut.changeLogsVisibilityStatus(true)
        
        // When
        sut.logRequest(request)
        
        // Then
        XCTAssertTrue(capturedOutput.contains { $0.contains("Request ---> GET https://example.com") })
        XCTAssertTrue(capturedOutput.contains { $0.contains("Headers: [\"Content-Type\": \"application/json\"]") })
        XCTAssertTrue(capturedOutput.contains { $0.contains("Body: {\"key\":\"value\"}") })
    }
    
    func test_logResponse_shouldNotPrintWhenNeedToShowLogsIsFalse() {
        
        // Given
        let response = createDummyHTTPURLResponse()
        sut.changeLogsVisibilityStatus(false)
        
        // When
        sut.logResponse(response, data: nil)
        
        // Then
        XCTAssertTrue(capturedOutput.isEmpty)
    }
    
    func test_logResponse_shouldLogResponseCorrectlyIdDataIsEmpty() {
        
        // Given
        let response = createDummyHTTPURLResponse()
        sut.changeLogsVisibilityStatus(true)
        
        // When
        sut.logResponse(response, data: nil)
        
        // Then
        XCTAssertFalse(capturedOutput.isEmpty)
        XCTAssertTrue(capturedOutput.contains { $0.contains("Response ---> 200 from https://example.com") })
    }
    
    func test_logResponse_shouldLogResponseCorrectlyIdDataIsNotEmpty() {
        
        // Given
        let response = createDummyHTTPURLResponse()
        sut.changeLogsVisibilityStatus(true)
        let expectedData = String(data: createDummyData(), encoding: .utf8)!
        
        // When
        sut.logResponse(response, data: createDummyData())
        
        // Then
        XCTAssertFalse(capturedOutput.isEmpty)
        XCTAssertTrue(capturedOutput.contains { $0.contains("Body: \(expectedData)") })
    }

    func test_logError_shouldNotPrintWhenNeedToShowLogsIsFalse() {
        
        // Given
        let request = createDummyURLRequest()
        sut.changeLogsVisibilityStatus(false)
        
        // When
        sut.logError(NetworkError.general, for: request)
        
        // Then
        XCTAssertTrue(capturedOutput.isEmpty)
    }
    
    func test_logError_shouldPrintError() {
        
        // Given
        let request = createDummyURLRequest()
        sut.changeLogsVisibilityStatus(true)
        
        // When
        sut.logError(NetworkError.general, for: request)
        
        // Then
        XCTAssertFalse(capturedOutput.isEmpty)
        XCTAssertTrue(capturedOutput.contains { $0.contains("Error Something went wrong for GET") })
    }
    
}

private extension NetworkLoggerTests {
    
    func createDummyURLRequest() -> URLRequest {
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"key\":\"value\"}".data(using: .utf8)
        
        return request
    }
    
    func createDummyHTTPURLResponse() -> HTTPURLResponse {
        let url = URL(string: "https://example.com")!
        return HTTPURLResponse(url: url,
                               statusCode: 200,
                               httpVersion: nil,
                               headerFields: nil)!
    }
    
    func createDummyData() -> Data {
        let mockData: MockData = .init(key: "Key")
        return try! JSONEncoder().encode(mockData)
    }
}
