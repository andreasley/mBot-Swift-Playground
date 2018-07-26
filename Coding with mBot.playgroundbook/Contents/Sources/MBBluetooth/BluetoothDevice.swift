//
//  BluetoothDevice.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/4.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralError: MBError {
    case notFoundService
    case notFoundCharacteristic
    case notConnected
    
    var code: String { return "" }
    var description: String { return "" }
}

public class Peripheral: NSObject, Device, CBPeripheralDelegate, DeviceInfoUpdatable {
    public var name = ""
    public var uuid = ""
    public var rssi: Float = 100
    public var state: DeviceState = .disconnected
    var peripheral: CBPeripheral!
    var writeChar: CBCharacteristic? = nil
    var peripheralDelegate: PeripheralServiceAndCharacteristicDelegate!
    
    private var sendHandler: ((Result<(Peripheral, Data)>)->())?
    
    public override var description: String {
        return "\(name) uuid:\(uuid) rssi:\(rssi) state:\(state)"
    }
    
    init(peripheral: CBPeripheral, rssi: Float? = nil) {
        super.init()
        self.peripheral = peripheral
        peripheral.delegate = self
        state = state(origin: peripheral.state)
        name = peripheral.name ?? ""
        uuid = peripheral.identifier.uuidString
        if let r = rssi {
            self.rssi = r
        }
    }
    
    func send(data: Data, to writeChar: CBCharacteristic, type: CBCharacteristicWriteType, handler: ((Result<(Peripheral, Data)>)->())?) {
        peripheral.writeValue(data, for: writeChar, type: type)
        sendHandler = handler
    }
    //MARK: Delegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let del = peripheralDelegate {
            del.peripheral(peripheral: self, didDiscover: peripheral.services, error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let del = peripheralDelegate {
            del.peripheral(self, didDiscover: service.characteristics, error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        rssi = RSSI.floatValue
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.value ?? "null")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let handler = self.sendHandler else {
            return
        }
        if let data = characteristic.value {
//            let text = data.bytes.reduce("", { (r, ele) -> String in
//                return r + "\(ele)"
//            })
//            Log(text)
            handler(.success(self, data))
        } else {
            handler(.failure(error: DeviceError.nullData))
        }
    }
    
    //MARK: Private
    private func state(origin: CBPeripheralState) -> DeviceState {
        switch origin {
        case .connected:
            return .connected
        case .disconnected:
            return .disconnected
        case .connecting:
            return .connecting
        case .disconnecting:
            return .disconnecting
        }
    }
    
}
