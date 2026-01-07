import Foundation
import Network
import Combine
import RxSwift
import RxRelay

@available(iOS 17.4, *)
public enum NetworkInterfaceType: String, Codable, Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case loopback
    case other
    case unknown

    init(from nw: NWInterface.InterfaceType?) {
        guard let t = nw else { self = .unknown; return }
        switch t {
        case .wifi: self = .wifi
        case .cellular: self = .cellular
        case .wiredEthernet: self = .wiredEthernet
        case .loopback: self = .loopback
        default: self = .other
        }
    }
}

@available(iOS 17.4, *)
public struct NetworkStatus: Equatable {
    public let isConnected: Bool
    public let interface: NetworkInterfaceType
    public let rawStatus: NWPath.Status

    public init(isConnected: Bool, interface: NetworkInterfaceType = .unknown, rawStatus: NWPath.Status = .requiresConnection) {
        self.isConnected = isConnected
        self.interface = interface
        self.rawStatus = rawStatus
    }
}

/// NetworkMonitor exposes current network state via Combine, RxSwift and Swift concurrency.
/// - Features:
///   - `statusPublisher` (Combine) publishes `NetworkStatus`
///   - `statusObservable` (RxSwift) is an Observable stream of `NetworkStatus`
///   - `isConnectedPublisher` / `isConnectedObservable` convenience streams for Bool
@available(iOS 17.4, *)
public final class NetworkMonitor {

    // MARK: - Public
    public static let shared = NetworkMonitor()

    /// Combine publisher of detailed network status (CurrentValue semantics)
    public private(set) var statusPublisher: AnyPublisher<NetworkStatus, Never>

    /// Combine publisher of connection boolean
    public private(set) var isConnectedPublisher: AnyPublisher<Bool, Never>

    /// RxSwift observable for detailed network status
    public var statusObservable: Observable<NetworkStatus> { statusRelay.asObservable() }

    /// RxSwift observable for connection boolean
    public var isConnectedObservable: Observable<Bool> { statusRelay.map { $0.isConnected }.distinctUntilChanged() }

    /// Current status snapshot
    public private(set) var currentStatus: NetworkStatus {
        statusSubject.value
    }

    // MARK: - Private
    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue

    private let statusSubject: CurrentValueSubject<NetworkStatus, Never>
    private let statusRelay: BehaviorRelay<NetworkStatus>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    public init(requiredInterface: NWInterface.InterfaceType? = nil) {
        monitor = NWPathMonitor(requiredInterfaceType: requiredInterface ?? .other)
        monitorQueue = DispatchQueue(label: "com.rxstudy.network.monitor")

        let initial = NetworkStatus(isConnected: false, interface: .unknown, rawStatus: .requiresConnection)
        statusSubject = CurrentValueSubject(initial)
        statusRelay = BehaviorRelay(value: initial)

        // expose publishers
        statusPublisher = statusSubject.eraseToAnyPublisher()
        isConnectedPublisher = statusPublisher.map { $0.isConnected }.removeDuplicates().eraseToAnyPublisher()

        start()
    }

    deinit {
        stop()
    }

    // MARK: - Control
    /// Start monitoring (called in init by default)
    public func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let isConnected = (path.status == .satisfied)
            let ifType = NetworkInterfaceType(from: path.availableInterfaces.first?.type)
            let newStatus = NetworkStatus(isConnected: isConnected, interface: ifType, rawStatus: path.status)

            // publish on main because consumers often update UI
            DispatchQueue.main.async {
                self.statusSubject.send(newStatus)
                self.statusRelay.accept(newStatus)
            }
        }
        monitor.start(queue: monitorQueue)

        // Seed from current path if available (i.e., on init)
        if let currentPath = monitor.currentPathIfAvailable() {
            let isConnected = (currentPath.status == .satisfied)
            let ifType = NetworkInterfaceType(from: currentPath.availableInterfaces.first?.type)
            let seed = NetworkStatus(isConnected: isConnected, interface: ifType, rawStatus: currentPath.status)
            statusSubject.send(seed)
            statusRelay.accept(seed)
        }
    }

    /// Stop monitoring
    public func stop() {
        monitor.cancel()
    }
}

// MARK: - NWPathMonitor helper
private extension NWPathMonitor {
    func currentPathIfAvailable() -> NWPath? {
        // NWPathMonitor doesn't provide a stable "current path" accessor, but `currentPath` is available on macOS/iOS.
        // use key-value access with caution — this is defensive and best-effort.
        return self.value(forKey: "currentPath") as? NWPath
    }
}

// MARK: - Usage example
/*
import Combine
import RxSwift

@available(iOS 17.4, *)
func example() {
    let monitor = NetworkMonitor.shared

    // Combine
    let cancellable = monitor.statusPublisher.sink { status in
        print("Combine: isConnected=\(status.isConnected), interface=\(status.interface)")
    }

    // RxSwift
    let disposable = monitor.statusObservable.subscribe(onNext: { status in
        print("Rx: isConnected=\(status.isConnected), interface=\(status.interface)")
    })

    // remember to cancel/dispose when done
    _ = (cancellable, disposable)
}
*/