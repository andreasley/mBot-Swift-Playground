//
//  MBDeviceKit.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/3.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation

let lastConnectPeripheralStorygeKey = "LastConnectPeripheralStorygeKey"

//MARK: 请求

public protocol CommandOrigin {}
public protocol CommandTarget {}

extension Data: CommandOrigin {}
extension String: CommandOrigin {}
extension Data: CommandTarget {}
extension String: CommandTarget {}

/// 对命令进行转换
public protocol CommandInterpreter {
    func command(origin: CommandOrigin) -> CommandTarget
}

/// 默认请求参数转换
struct DefaultInterpreter: CommandInterpreter {
    func command(origin: CommandOrigin) -> CommandTarget {
        if let o = origin as? Data {
            return o
        }
        if let o = origin as? String {
            return o.data(using: .utf8) ?? Data()
        }
        return Data()
    }
}
/// 请求
public protocol Request {
    associatedtype Response: Decodable
    var interpreter: CommandInterpreter {get}
    var command: CommandOrigin {get}
    var method: Method {get}
}

extension Data: Decodable {
    public static func decode(data: Data) -> Data {
        return data
    }
}

extension Data: Request {
    public typealias Response = Data
    public var interpreter: CommandInterpreter {
        return DefaultInterpreter()
    }
    public var command: CommandOrigin {
        return self
    }
    public var method: Method {
        return .write
    }
}

//MARK: 解析

public protocol Decodable {
    static func decode(data: Data) -> Self
}

//MARK: 起飞
/// 数据发送
public protocol Launcher {
    associatedtype Element: Device
    var delegate: DeviceDelegate {get}
    func send<R: Request>(res: R, to device: Element)
}

//MARK: 外设

public protocol Device {
    var name: String {get set}
    var uuid: String {get set}
    var rssi: Float {get set}
    var state: DeviceState {get set}
    var primaryKey: String {get}
}

extension Device {
    public var primaryKey: String {
        return uuid
    }
}

protocol DeviceInfoUpdatable {
    mutating func update(use element: Device)
}

extension DeviceInfoUpdatable where Self: Device {
    mutating func update(use device: Device) {
        uuid = device.uuid
        name = device.name
        rssi = device.rssi
        state = device.state
    }
}

extension Array where Element: Device, Element: Equatable, Element: DeviceInfoUpdatable {
    mutating func update(use element: Element) {
        if let existIndex = index(of: element) {
            var existDevice = self[existIndex]
            existDevice.update(use: element)
        } else {
            append(element)
        }
    }
}


//MARK: 中央设备
/// 监听代理
public protocol CenterListener: class {
    func center<C: Center>(center: C, didDiscover devices: Result<[Device]>)
    func center<C: Center>(center: C, didChangeState: CenterState)
    func center<C: Center>(center: C, didConnect device: Result<Device>)
    func center<C: Center>(center: C, didPrepared device: Result<Device>)
    func center<C: Center>(center: C, device: Device, didReceive data: Result<Decodable>)
    func center<C: Center>(center: C, didDisconnect device: Result<Device>)
    func center<C: Center>(center: C, didUpdateForDevice: Device, allDevices: [Device])
}

extension CenterListener where Self: Any {
    public func center<C: Center>(center: C, didDiscover devices: Result<[Device]>) {}
    public func center<C: Center>(center: C, didChangeState: CenterState) {}
    public func center<C: Center>(center: C, didConnect device: Result<Device>) {}
    public func center<C: Center>(center: C, didPrepared device: Result<Device>) {}
    public func center<C: Center>(center: C, device: Device, didReceive data: Result<Decodable>) {}
    public func center<C: Center>(center: C, didDisconnect device: Result<Device>) {}
    public func center<C: Center>(center: C, didUpdateForDevice: Device, allDevices: [Device]) {}
}

/// 容纳设备的职能
protocol DeviceContainer: class {
    associatedtype Element: Device
    var connectedDevice: Element? {get}
    var connectedDeviceList: [Element] {get set}
    var foundDeviceList: [Element] {get set}
}

extension DeviceContainer {
    var connectedDevice: Element? {
        return connectedDeviceList.first
    }
}

public protocol DeviceDelegate {
    func device(_ device: Device, didReceive data: Result<Decodable>)
    func deviceDidPrepared(_ device: Result<Device>)
}

public class ListenerWeakWrapper {
    weak var value: CenterListener?
    
    init(value: CenterListener) {
        self.value = value
    }
}


/// 中央设备
public protocol Center {
    associatedtype Element: Device
    associatedtype Sender: Launcher
    var listeners: [CenterListener] {get}
    var config: CenterConfig<Element> {get set}
    
    var launcher: Sender {get}
    
    var lastConnectedDeviceID: String? {get}
    func rememberCurrentConnectedDevice(ID: String)
    
    func scan()
    func stopScan()
    func resetCenter()
    func connect(element: Element)
    func send<R: Request>(res: R, to device: Element)
    func disConnect(element: Element?)
}

extension Center where Self: DeviceContainer, Self.Element: Equatable, Self.Element: DeviceInfoUpdatable {
    var connectedDevice: Element? {
        return connectedDeviceList.first
    }
    
    /// 添加设备至发现列表
    ///
    /// - Parameter device: 待添加
    /// - Returns: 是否符合规定
    @discardableResult
    func addOrUpdateLegalDevice(device: Element) -> Bool {
        guard let filter = config.filter, filter(device) == true else {
            return false
        }
        foundDeviceList.update(use: device)
        return true
    }
    
    /// 排序发现列表
    func sortFoundDeviceList() {
        if let sorter = config.sorter {
            foundDeviceList = foundDeviceList.sorted(by: sorter)
        }
    }
    
    func disConnectAll() {
        connectedDeviceList.forEach({disConnect(element: $0)})
    }
}
