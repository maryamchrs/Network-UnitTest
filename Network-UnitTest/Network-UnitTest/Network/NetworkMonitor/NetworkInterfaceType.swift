//
//  NetworkInterfaceType.swift
//  Network-UnitTest
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation
import Network

enum NetworkInterfaceType : Sendable {
    
    /// A virtual or otherwise unknown interface type
    case other
    
    /// A Wi-Fi link
    case wifi
    
    /// A Cellular link
    case cellular
    
    /// A Wired Ethernet link
    case wiredEthernet
    
    /// The Loopback Interface
    case loopback
    
    init?(type: NWInterface.InterfaceType?) {
        switch type {
        case .other:
            self = .other
        case .wifi:
            self = .wifi
        case .cellular:
            self = .cellular
        case .wiredEthernet:
            self = .wiredEthernet
        case .loopback:
            self = .loopback
        default:
            self = .other
        }
    }
}
