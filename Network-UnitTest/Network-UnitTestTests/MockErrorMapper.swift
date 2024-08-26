//
//  MockErrorMapper.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 25/08/2024.
//

import Foundation
import XCTest
@testable import Network_UnitTest

final class MockErrorMapper: ErrorMapperProtocol {
    var mappedError: Error?
    
    func map(error: Error, response: HTTPURLResponse?, isNetworkReachable: Bool) -> Error {
        return mappedError ?? error
    }
    
}
