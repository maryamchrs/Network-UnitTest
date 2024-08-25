//
//  NWInterface.InterfaceType+Extension.swift
//  Network-UnitTest
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation
import Network

/// By conforming to `CaseIterable` protocol you can use `AllCases` to give all posible cases of an enum
/// `AllCases`:  A type that can represent a collection of all values of this type.
extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] {
        return [
            .other,
            .wifi,
            .cellular,
            .wiredEthernet,
            .loopback
        ]
    }
}
