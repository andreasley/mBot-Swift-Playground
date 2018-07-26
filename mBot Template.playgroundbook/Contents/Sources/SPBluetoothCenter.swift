import Foundation
import PlaygroundBluetooth
import CoreBluetooth

public class SPBLEManager {
    private init() {}
    static public var shared: SPBLECenter {
        return Loader.currentLiveViewController().bleMgr
    }
}


//MARL: SPBLECenter
public class SPBLECenter: NSObject, Center, DeviceContainer {
    
    static private let workingQueueLabel = "SPBLECenterQueue"
    
    fileprivate var listenerWrappers: [ListenerWeakWrapper] = []
    
    public var listeners: [CenterListener] {
        let a = listenerWrappers.filter {$0.value != nil}
        return a.map{$0.value!}
    }
    
    public typealias Element = Peripheral
    public typealias Sender = BLELauncher
    
    var connectedDeviceList: [Element] = []
    var connectedDevice: Element?
    var foundDeviceList: [Element] = []
    
    public var launcher: Sender {
        return Sender(delegate: self)
    }
    var configurator: MBPeripheralConfigurator {
        return MBPeripheralConfigurator(delegate: self)
    }
    /// 管理器配置
    lazy public var config: CenterConfig<Element> = {
        return CenterConfig.init(
            filter: { (device) -> (Bool) in
                return device.rssi > -60 && device.name.hasPrefix(Makeblock.devicePrefix)
        },
            sorter: { (a, b) -> Bool in
                return a.rssi > b.rssi
        },
            maxConnectedCount: 1,
            shouldAutoConnectDevice: false,
            shouldConnectWhileClose: true,
            shouldAutoRefreshDevices: false,
            enableLog: true)
    }()
    
    public lazy var centralManager: PlaygroundBluetoothCentralManager = {
        let centralManager = PlaygroundBluetoothCentralManager(services: nil, queue: .main)
        centralManager.delegate = self
        return centralManager
    }()
    
    public func scan() {
    }
    
    public func connect(element: Element) {
        if config.maxConnectedCount > connectedDeviceList.count {
            stopScan()
        }
    }
    
    public func prepare(element: Element) {
        configurator.prepare(device: element)
    }
    
    public func send<R: Request>(res: R, to device: Element) {
        launcher.send(res: res, to: device)
    }
    
    public func disConnect(element: Element? = nil) {
        
    }
    
    public func resetCenter() {
        connectedDeviceList.removeAll()
        listenerWrappers.removeAll()
    }
    
    public func stopScan() {

    }
    
}

// MARK: - Center扩展
extension SPBLECenter {
    public var lastConnectedDeviceID: String? {
        return UserDefaults.standard.string(forKey: lastConnectPeripheralStorygeKey)
    }
    
    public func rememberCurrentConnectedDevice(ID: String) {
        UserDefaults.standard.set(ID, forKey: lastConnectPeripheralStorygeKey)
    }
    
    func addListener(listener: CenterListener) {
        if !listeners.contains() { $0 === listener } {
            listenerWrappers.append(ListenerWeakWrapper(value: listener))
        }
        for (i, obj) in listenerWrappers.enumerated() {
            if obj.value == nil && i < listenerWrappers.count {
                listenerWrappers.remove(at: i)
            }
        }
    }
    func removeListener(listener: CenterListener) {
        guard let index = listenerWrappers.index(where: {$0.value === listener}) else {return}
        listenerWrappers.remove(at: index)
    }
    
}


// MARK: - Delegate
extension SPBLECenter: PlaygroundBluetoothCentralManagerDelegate, DeviceDelegate {
    
    public func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {

    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) {

    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {

    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        let pr = Peripheral.init(peripheral: peripheral)
        prepare(element: pr)
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
        
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        
    }
    
    /////

    ///设备回调
    
    public func deviceDidPrepared(_ device: Result<Device>) {
        if case let .success(value) = device, let d = value as? SPBLECenter.Element, d.state == .prepared {
            connectedDevice = d
            listeners.forEach {$0.center(center: self, didPrepared: device)}
        }
    }
    
    public func device(_ device: Device, didReceive data: Result<Decodable>) {
        if case let .success(data) = data {
            log(device)
            listeners.forEach {$0.center(center: self, device: device, didReceive: .success(data))}
        }
    }
    
    //MARK: Private
    
    fileprivate func log(_ items: Any..., separator: String = "\n", terminator: String = "") {
        if config.enableLog {
            print(separator)
            print(items, separator: separator, terminator: terminator)
        }
    }
    
    private func centerState(origin: CBManagerState) -> CenterState {
        switch origin {
        case .poweredOff:
            return .poweredOff
        case .poweredOn:
            return .poweredOn
        case .resetting:
            return .resetting
        case .unauthorized:
            return .unauthorized
        case .unsupported:
            return .unsupported
        case .unknown:
            return .unknown
        }
    }
    
    private func device(with peripheral: CBPeripheral) -> Peripheral? {
        return foundDeviceList.filter{$0.peripheral == peripheral}.first
    }
}
