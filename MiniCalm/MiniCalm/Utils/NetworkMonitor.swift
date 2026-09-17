import Foundation
import Network

final class NetworkMonitor {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    // Callback to notify when the network drops
    var onConnectionLost: (() -> Void)?
    
    // Tracks if we were previously connected so we don't spam alerts
    private var wasConnected = true
    
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = (path.status == .satisfied)
            
            // If the connection drops from true to false, trigger the callback
            if self?.wasConnected == true && !isConnected {
                DispatchQueue.main.async {
                    self?.onConnectionLost?()
                }
            }
            self?.wasConnected = isConnected
        }
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
}
