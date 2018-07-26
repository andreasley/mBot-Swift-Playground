//
//  BlueToothProvider.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/4.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BLELauncher: Launcher {
    public typealias Element = Peripheral
    public var delegate: DeviceDelegate
    init(delegate: DeviceDelegate) {
        self.delegate = delegate
    }
    public func send<R>(res: R, to device: Element) where R : Request {
        guard device.state == .prepared, let characteristic = device.writeChar else {
            delegate.device(device, didReceive: .failure(error: PeripheralError.notFoundCharacteristic))
            return
        }
        guard  let data = res.interpreter.command(origin: res.command) as? Data else {
            delegate.device(device, didReceive: .failure(error: CenterError.commandIncorrect))
            return
        }
        var method: CBCharacteristicWriteType!
        switch res.method {
        case .transition:
            method = .withResponse
        case .write:
            method = .withoutResponse
        default:
            break
        }
        device.send(data: data, to: characteristic, type: method, handler: { result in
            if case let .success(value) = result {
                self.delegate.device(device, didReceive: .success(R.Response.decode(data: value.1)))
            }
        })
        
    }
    
}

protocol PeripheralServiceAndCharacteristicDelegate {
    func peripheral(peripheral: Peripheral, didDiscover services: [CBService]?, error: Error?)
    func peripheral(_ peripheral: Peripheral, didDiscover characteristics: [CBCharacteristic]?, error: Error?)
}

/// 具体实现
public final class MBPeripheralConfigurator: PeripheralServiceAndCharacteristicDelegate {
    var delegate: DeviceDelegate
    private var device: Peripheral?
    
    init(delegate: DeviceDelegate) {
        self.delegate = delegate
    }
    
    public func prepare(device: Peripheral) {
        self.device = device
        device.peripheralDelegate = self
        device.peripheral.discoverServices(nil)
    }
    
    //Props
    private var isDual: Bool = false
    private var resetService: CBService? = nil
    private var transService: CBService? = nil
    private var resetCharateristic: CBCharacteristic? = nil
    private var transCharateristic: CBCharacteristic? = nil
    private var notifyCharateristic: CBCharacteristic? = nil
    
    func peripheral(peripheral: Peripheral, didDiscover services: [CBService]?, error: Error?) {
        guard let s = services else { return }
        for service in s {
            switch service.uuid {
            case CBUUID.transDataService:
                peripheral.peripheral.discoverCharacteristics([.transDataCharateristic, .transDataDualCharateristic, .notifyDataCharateristic, .notifyDataDualCharateristic], for: service)
            case CBUUID.transDataDualService:
                isDual = true
                peripheral.peripheral.discoverCharacteristics([.transDataCharateristic, .transDataDualCharateristic, .notifyDataCharateristic, .notifyDataDualCharateristic], for: service)
            default:
                continue
            }
        }
    }
    
    func peripheral(_ peripheral: Peripheral, didDiscover characteristics: [CBCharacteristic]?, error: Error?) {
        guard let c = characteristics, error == nil else {
            return
        }
        for characteristic in c {
            switch characteristic.uuid {
            case CBUUID.transDataCharateristic,CBUUID.transDataDualCharateristic:
                transCharateristic = characteristic
            case CBUUID.notifyDataCharateristic,CBUUID.notifyDataDualCharateristic:
                notifyCharateristic = characteristic
                peripheral.peripheral.setNotifyValue(true, for: characteristic)
            default:
                continue
            }
            manageDeviceState()
        }
    }
    
    //MARK: Private
    private func manageDeviceState() {
        if let device = self.device, notifyCharateristic != nil && transCharateristic != nil {
            self.device!.writeChar = transCharateristic
            self.device!.state = .prepared
            self.delegate.deviceDidPrepared(.success(device))
        }
    }
}
