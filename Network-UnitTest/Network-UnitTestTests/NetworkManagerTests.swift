//
//  NetworkManagerTests.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 25/08/2024.
//

import Combine
import XCTest
@testable import Network_UnitTest

final class NetworkManagerTests: XCTestCase {
    
    struct MockResponse: Codable, Equatable {
        let key: String
    }
    
    enum UseCases {
        case success
        case failure(statusCode: Int)
        case successWithAppropriateObject
        case successWithEmptyData
    }
    
    var sut: NetworkManager!
    var mockHTTPClient: MockHTTPClient!
    var mockRequestMapper: MockRequestMapper!
    var mockErrorMapper: MockErrorMapper!
    var spyNetworkLogger: SpyNetworkLogger!
    
    var dummyUrl: URL!
    var dummyURLRequest: URLRequest!
    let dummyObject = MockResponse(key: "key")
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        dummyUrl = URL(string: "www.dummy.com")!
        dummyURLRequest = URLRequest(url: dummyUrl)
        
        mockHTTPClient = MockHTTPClient()
        mockRequestMapper = MockRequestMapper()
        mockErrorMapper = MockErrorMapper()
        spyNetworkLogger = SpyNetworkLogger()
        sut = NetworkManager(
            client: mockHTTPClient,
            requestMapper: mockRequestMapper,
            errorMapper: mockErrorMapper,
            logger: spyNetworkLogger
        )
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockHTTPClient = nil
        mockRequestMapper = nil
        mockErrorMapper = nil
        cancellables = nil
        
        dummyUrl = nil
        dummyURLRequest = nil
        super.tearDown()
    }
    
    func test_requestCalled_shouldCallLogRequest() {
        // Given
        spyNetworkLogger.logRequestCalled = false
        
        // When
        sut.request(dummyURLRequest)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { (_: MockResponse) in })
            .store(in: &cancellables)
        
        // Then
        XCTAssertTrue(spyNetworkLogger.logRequestCalled, "logRequestCalled should be called.")
    }
    
    
    func test_requestCalled_shouldThrowError() {
        // Given
        mockHTTPClient.publisherError = NetworkError.general
        spyNetworkLogger.loggedError = nil
        spyNetworkLogger.logErrorCalled = false
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        sut.request(dummyURLRequest)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure:
                    expectation.fulfill()
                }
            }, receiveValue: { (_: MockResponse) in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(spyNetworkLogger.loggedError)
        XCTAssertTrue(spyNetworkLogger.logErrorCalled)
    }
    
    func test_requestCalled_shouldReturnDataSuccessfully() throws {
        // Given
        let expectedResponse = makeResponse(useCase: .successWithAppropriateObject)
        mockHTTPClient.publisherDataResponse = expectedResponse
        var responseModel: MockResponse?
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        sut.request(dummyURLRequest)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { (model : MockResponse) in
                responseModel = model
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertNotNil(responseModel)
        guard let responseModel,
              let dummyResponse = expectedResponse?.0,
              let expectedObject = try? JSONDecoder().decode(
                MockResponse.self,
                from: dummyResponse
              )  else {
            assertionFailure()
            return
        }
        XCTAssertEqual(responseModel, expectedObject)
    }
    
    func test_requestCalled_shouldLogResponse() throws {
        // Given
        mockHTTPClient.publisherDataResponse = makeResponse(useCase: .successWithAppropriateObject)
        spyNetworkLogger.logResponseCalled = false
        
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        sut.request(dummyURLRequest)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { ( model : MockResponse) in
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(spyNetworkLogger.logResponseCalled)
    }
    
    func test_requestCalled_shouldThrowUnableToDecodeIfCanNotDecodeTheModel() throws {
        // Given
        let expectedResponse = makeResponse(useCase: .successWithEmptyData)
        mockHTTPClient.publisherDataResponse = expectedResponse
        spyNetworkLogger.logResponseCalled = false
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        sut.request(dummyURLRequest)
            .sink(receiveCompletion: {  completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                    expectation.fulfill()
                }
            }, receiveValue: { (_: MockResponse) in
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(receivedError as? NetworkError, NetworkError.unableToDecode)
    }
    
    func test_asyncRequestCalled_shouldCallLogRequest() async {
        let expectedResponse = makeResponse(useCase: .successWithAppropriateObject)
        mockHTTPClient.performDataResponse = expectedResponse
        spyNetworkLogger.logRequestCalled = false
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        do {
            let _: MockResponse = try await sut.request(dummyURLRequest)
            expectation.fulfill()
        } catch {
            assertionFailure()
        }
        
        await fulfillment(of: [expectation])
        
        // Then
        XCTAssertTrue(spyNetworkLogger.logRequestCalled, "logRequestCalled should be called in request()")
    }
    
    func test_asyncRequestCalled_shouldCallLogResponse() async {
        let expectedResponse = makeResponse(useCase: .successWithAppropriateObject)
        mockHTTPClient.performDataResponse = expectedResponse
        spyNetworkLogger.logResponseCalled = false
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        do {
            let _: MockResponse = try await sut.request(dummyURLRequest)
            expectation.fulfill()
        } catch {
            assertionFailure()
        }
        
        await fulfillment(of: [expectation])
        
        // Then
        XCTAssertTrue(spyNetworkLogger.logResponseCalled)
    }
    
    func test_asyncRequestCalled_shouldCallLogErrorIfGetsError() async {
        let expectedResponse = makeResponse(useCase: .successWithEmptyData)
        mockHTTPClient.performDataResponse = expectedResponse
        spyNetworkLogger.logErrorCalled = false
        let expectation = XCTestExpectation(description: "Error handling expectation")
        
        // When
        do {
            let _: MockResponse = try await sut.request(dummyURLRequest)
        } catch {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation])
        
        // Then
        XCTAssertTrue(spyNetworkLogger.logErrorCalled)
    }
}

private extension NetworkManagerTests {
    func makeResponse(useCase: UseCases) -> (Data, HTTPURLResponse)? {
        switch useCase {
        case .success:
            let model = try! JSONEncoder().encode(dummyObject)
            return (
                model,
                HTTPURLResponse(
                    url: dummyUrl,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
            
        case .failure(let statusCode):
            let model = try! JSONEncoder().encode(dummyObject)
            return (
                model,
                HTTPURLResponse(
                    url: dummyUrl,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        case .successWithAppropriateObject:
            let model = try! JSONEncoder().encode(dummyObject)
            return (
                model,
                HTTPURLResponse(
                    url: dummyUrl,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        case .successWithEmptyData:
            let model = try! JSONEncoder().encode(Data())
            return (
                model,
                HTTPURLResponse(
                    url: dummyUrl,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        }
    }
}
