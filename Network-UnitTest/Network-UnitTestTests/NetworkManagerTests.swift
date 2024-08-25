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
    
    struct MockResponse: Decodable, Equatable {
        let key: String
    }
    
    var sut: NetworkManager!
    
    var mockHTTPClient: MockHTTPClient!
    var mockRequestMapper: MockRequestMapper!
    var mockErrorMapper: MockErrorMapper!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        mockRequestMapper = MockRequestMapper()
        mockErrorMapper = MockErrorMapper()
        sut = NetworkManager(
            client: mockHTTPClient,
            requestMapper: mockRequestMapper,
            errorMapper: mockErrorMapper
        )
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockHTTPClient = nil
        mockRequestMapper = nil
        mockErrorMapper = nil
        cancellables = nil
        super.tearDown()
    }
}
