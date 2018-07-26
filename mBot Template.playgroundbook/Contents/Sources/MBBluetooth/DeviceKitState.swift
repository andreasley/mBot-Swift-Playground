//
//  DeviceKitState.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/7.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation

/// 请求方法
///
/// - write: writeWithputResponse
/// - transition: writeWithResponse
/// - reset: 重置
public enum Method {
    case write
    case transition
    case reset
}

//MARK: 错误

public enum Result<T>{
    case success(T)
    case failure(error: Error)
}

public enum CenterError: MBError {
    case connectManualFailed
    case connectAutoFailed
    case disconnectSudden
    case disconnectFailed
    case searchedNothing
    case sendFailed
    case responseNull
    case responseTimeout
    case responseIllegal
    case notReadyForDevice
    case commandIncorrect
    
    public var code: String { return "" }
    public var description: String { return "" }
}

public enum DeviceError: MBError {
    case notConnected
    case disconnectSudden
    case notReady
    case nullData
    
    public var code: String { return "" }
    public var description: String { return "" }
}

public protocol MBError: Error {
    var code: String {get}
    var description: String {get}
}

//MARK: 状态

public enum CenterState {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

public enum DeviceState {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case prepared
    case notPrepared
}

//MARK: 中央设备配置参数
public struct CenterConfig<T: Device> {
    typealias FilterOnDevices = (T)->(Bool)
    typealias SorterOnDevices = (T, T) -> Bool
    
    var filter: FilterOnDevices? = nil
    var sorter: SorterOnDevices? = nil
    var maxConnectedCount: Int = 1
    var shouldAutoConnectDevice: Bool = true
    var shouldConnectWhileClose: Bool = true
    var shouldAutoRefreshDevices: Bool = true
    var enableLog: Bool = true
}

