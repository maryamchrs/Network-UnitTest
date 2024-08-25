//
//  NetworkMonitor.swift
//
//  Created by Maryam Chrs on 10/07/2024.
//

import Foundation
import Network
import Combine

protocol NetworkMonitorProtocol: AnyObject {
    
    /// The startMonitoringNetwork method starts monitoring the network status and provides updates through an AsyncStream<NetworkInfoModel>. This method leverages the NWPathMonitor to observe changes in the network path, such as connectivity status and interface type. It returns an AsyncStream that yields NetworkInfoModel instances, encapsulating the network status and interface information.
    /// - Returns:
    ///  AsyncStream<NetworkInfoModel>:  An asynchronous stream of NetworkInfoModel instances, providing real-time updates about network connectivity.
    func startMonitoringNetwork() -> AsyncStream<NetworkInfoModel>
    
    
    /// The startMonitoringNetwork method initiates network monitoring using Combine's AnyPublisher<NetworkInfoModel, Never> to provide updates on network connectivity and interface type changes. It utilizes NWPathMonitor to observe changes in network paths and publishes NetworkInfoModel instances whenever there's a change in connectivity.
    /// - Returns:
    ///  AnyPublisher<NetworkInfoModel, Never>:  A publisher that emits NetworkInfoModel instances representing the current network status and interface type.
    func startMonitoringNetwork() -> AnyPublisher<NetworkInfoModel, Never>
    
    
    /// The startMonitoringNetwork method stop monitoring the network
    func stopMonitoringNetwork()
}

final class NetworkMonitor {
    
    // MARK: - Properties and Constans
    
    // MARK: Private
    private var monitor: NWPathMonitor?
    private let queue: DispatchQueue = DispatchQueue(label: "Network_Monitor_Queue")
    
    private var continuation: AsyncStream<NetworkInfoModel>.Continuation?
    private var cancellable: AnyCancellable?
    
    // MARK: Public
    
    // MARK: - Life Cycle of the class
    init() {
        debugPrint("NetworkMonitor initiated.")
    }
    
    deinit {
        stopMonitoringNetwork()
        debugPrint("NetworkMonitor deinited.")
    }
}

// MARK: - NetworkMonitorProtocol

extension NetworkMonitor: NetworkMonitorProtocol {
    
    /// The startMonitoringNetwork method starts monitoring the network status and provides updates through an AsyncStream<NetworkInfoModel>. This method leverages the NWPathMonitor to observe changes in the network path, such as connectivity status and interface type. It returns an AsyncStream that yields NetworkInfoModel instances, encapsulating the network status and interface information.
    /// - Returns:
    ///  AsyncStream<NetworkInfoModel>:  An asynchronous stream of NetworkInfoModel instances, providing real-time updates about network connectivity.
    func startMonitoringNetwork() -> AsyncStream<NetworkInfoModel> {
        /*
         TIP: once the NWPathMonitor is canceled, it cannot be restarted without reinitialization.
         To address this, we need to ensure that a new instance of NWPathMonitor is created each time monitoring is started.
         */
        AsyncStream { [weak self] continuation in
            
            guard let self = self else {
                continuation.finish()
                return
            }
            
            let monitor = NWPathMonitor()
            self.monitor = monitor
            self.continuation = continuation
            
            monitor.pathUpdateHandler = { [weak self] path in
                guard let self else { return }
                let networkData = self.generateRelatedData(from: path)
                continuation.yield(networkData)
            }
            
            monitor.start(queue: queue)
            
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.stopMonitoringNetwork()
            }
        }
    }
    
    /// The startMonitoringNetwork method initiates network monitoring using Combine's AnyPublisher<NetworkInfoModel, Never> to provide updates on network connectivity and interface type changes. It utilizes NWPathMonitor to observe changes in network paths and publishes NetworkInfoModel instances whenever there's a change in connectivity.
    /// - Returns:
    ///  AnyPublisher<NetworkInfoModel, Never>:  A publisher that emits NetworkInfoModel instances representing the current network status and interface type.
    func startMonitoringNetwork() -> AnyPublisher<NetworkInfoModel, Never> {
        /*
         TIP: once the NWPathMonitor is canceled, it cannot be restarted without reinitialization.
         To address this, we need to ensure that a new instance of NWPathMonitor is created each time monitoring is started.
         */
        monitor = NWPathMonitor()
        let publisher = PassthroughSubject<NetworkInfoModel, Never>()
        
        monitor?.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let networkData = self.generateRelatedData(from: path)
            publisher.send(networkData)
        }
        
        monitor?.start(queue: queue)
        
        cancellable = publisher
            .handleEvents(receiveCancel: { [weak self] in
                self?.stopMonitoringNetwork()
            })
            .eraseToAnyPublisher()
            .sink(receiveValue: { _ in }) /// Sink to keep the publisher alive
        
        return publisher.eraseToAnyPublisher()
    }
    
    /// The startMonitoringNetwork method stop monitoring the network
    func stopMonitoringNetwork() {
        monitor?.cancel()
        cancellable?.cancel()
        continuation?.finish()
        cancellable = nil
        continuation = nil
    }
}

// MARK: - Private methods

extension NetworkMonitor {
    
    /// A generator method that convert `NWPath` to `NetworkInfoModel`
    /// - Parameter
    ///  path: An NWPath object represents a snapshot of network path state.
    /// - Returns:
    ///  NetworkInfoModel
    private func generateRelatedData(from path: NWPath) -> NetworkInfoModel {
        let connectionType = NWInterface.InterfaceType.AllCases()
        return NetworkInfoModel(isActive: path.status == .satisfied,
                                isExpensive: path.isExpensive,
                                isConstrained: path.isConstrained,
                                connectionType: .init(type: connectionType.first(where: path.usesInterfaceType)) ?? .other)
    }
}


