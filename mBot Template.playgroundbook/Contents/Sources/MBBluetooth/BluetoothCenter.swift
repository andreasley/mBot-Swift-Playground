//
//  BluetoothCenter.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/4.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BLEManager {
    private init() {}
    static public let shared: BLECenter = BLECenter()
}


//MARL: BLECenter
public class BLECenter: NSObject, Center, DeviceContainer {
    
    static private let workingQueueLabel = "BLECenterQueue"
    
    fileprivate var listenerWrappers: [ListenerWeakWrapper] = []
    
    public var listeners: [CenterListener] {
        let a = listenerWrappers.filter {$0.value != nil}
        return a.map{$0.value!}
    }
    
    public typealias Element = Peripheral
    public typealias Sender = BLELauncher
    
    var connectedDeviceList: [Element] = []
    var connectedDevice: Element? {
        return connectedDeviceList.first
    }
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
    
    lazy var centralManager: CBCentralManager = {
        return CBCentralManager.init(delegate: self, queue: nil)
    }()
    
    public func scan() {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    public func connect(element: Element) {
        if config.maxConnectedCount > connectedDeviceList.count {
            centralManager.connect(element.peripheral, options: nil)
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
        guard let device = connectedDevice else {
            return
        }
        if let ele = element {
            centralManager.cancelPeripheralConnection(ele.peripheral)
        } else {
            centralManager.cancelPeripheralConnection(device.peripheral)
        }
    }
    
    public func resetCenter() {
        centralManager.stopScan()
        connectedDeviceList.forEach({centralManager.cancelPeripheralConnection($0.peripheral)})
        connectedDeviceList.removeAll()
        listenerWrappers.removeAll()
        centralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.init(label: BLECenter.workingQueueLabel))
    }
    
    public func stopScan() {
        centralManager.stopScan()
    }
    
}

// MARK: - Center扩展
extension BLECenter {
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
extension BLECenter: CBCentralManagerDelegate, DeviceDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        if central.state == .poweredOn {
            scan()
        } else {
            stopScan()
        }
        listeners.forEach {$0.center(center: self, didChangeState: centerState(origin: central.state))}
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var deviceT: Peripheral!
        if let pr = device(with: peripheral) {
            deviceT = pr
        } else {
            deviceT = Peripheral.init(peripheral: peripheral)
        }
        deviceT.rssi = RSSI.floatValue
        addOrUpdateLegalDevice(device: deviceT)
        sortFoundDeviceList()
        listeners.forEach {$0.center(center: self, didDiscover: .success(foundDeviceList))}
        log(deviceT)
        
        if config.shouldAutoConnectDevice, let lastID = lastConnectedDeviceID, lastID == deviceT.primaryKey {
            connect(element: deviceT)
        }
        if config.shouldConnectWhileClose {
            foundDeviceList.forEach { pr in
                if pr.rssi > -35 && pr.rssi < 0 {
                    connect(element: deviceT)
                }
            }
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("连接成功: \(peripheral.name ?? "none")" + peripheral.identifier.uuidString )
        stopScan()
        if let pr = device(with: peripheral) {
            listeners.forEach {$0.center(center: self, didConnect: .success(pr))}
            prepare(element: pr)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log("\(peripheral)\(String(describing: error))")
        listeners.forEach {$0.center(center: self, didDisconnect: .failure(error: CenterError.connectManualFailed))}
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let pr = device(with: peripheral) {
            pr.state = .disconnected
            log("断开连接: \(pr.name )" + peripheral.identifier.uuidString )
        }
        
        listeners.forEach {$0.center(center: self, didDisconnect: .failure(error: DeviceError.disconnectSudden))}
    }
    
    ///设备回调
    
    public func deviceDidPrepared(_ device: Result<Device>) {
        if case let .success(value) = device, let d = value as? BLECenter.Element, d.state == .prepared {
            connectedDeviceList.update(use: d)
            rememberCurrentConnectedDevice(ID: d.name)
            log("准备完毕: \(d.name)" + d.peripheral.identifier.uuidString)
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



