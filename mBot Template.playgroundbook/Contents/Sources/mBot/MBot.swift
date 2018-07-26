//
//  MBot.swift
//  mZero-iOS
//
//  Created by CatchZeng on 2017/3/20.
//  Copyright © 2017年 Shenzhen Maker Works Technology Co., Ltd. All rights reserved.
//

import Foundation

open class MBot: NSObject, CenterListener {
    private var index = 0
    fileprivate var valueCallbacks: [Int : ((Float) -> Void)] = [:]
    private let parser = RJ25DataParser()
    fileprivate let interpreter = RJ25DataInterpreter()
    private var manager: SPBLECenter {
        return SPBLEManager.shared
    }
    public override init() {
        super.init()
        parser.delegate = self
        manager.addListener(listener: self)
    }
    
    deinit {
        manager.removeListener(listener: self)
    }
    
    public func center<C>(center: C, device: Device, didReceive data: Result<Decodable>) where C : Center {
        if case let .success(d) = data, let model = d as? Data {
            onReceivedData(model)
        }
    }
    
    // MARK: Public Methods
    
    open func setDCMotor(leftSpeed: Int, rightSpeed: Int) {
        send(command: JoystickCommand(leftSpeed: leftSpeed, rightspeed: rightSpeed))
    }
    
    open func setLed(position: RGBLEDPosition, red: Int, green: Int, blue: Int) {
        send(command: BoardLEDCommand(position: position, red: red, green: green, blue: blue, brightness: 0.1))
    }
    
    open func setBuzzer(pitch: MusicNotePitch, duration: MusicNoteDuration) {
        send(command: BuzzerCommand(pitch: pitch, duration: duration))
    }
    
    open func sendInfraredMessage(_ message: String) {
        send(command: InfraredSendCommand(msg: message))
    }
    
    open func getUltraSonic(_ port: RJ25Port = .port3, callback:@escaping ((Float) -> Void)) {
        let nextIndex = getNextIndex()
        valueCallbacks.updateValue(callback, forKey: nextIndex)
        send(command: UltraSonicCommand(index: UInt8(nextIndex), port: port))
    }
    
    open func getLightness(_ port: RJ25Port = .port6, callback:@escaping ((Float) -> Void)) {
        let nextIndex = getNextIndex()
        valueCallbacks.updateValue(callback, forKey: nextIndex)
        send(command: lightnessCommand(index: UInt8(nextIndex), port: port))
    }
    
    open func getLineFollower(_ port: RJ25Port = .port2, callback:@escaping ((Float) -> Void)) {
        let nextIndex = getNextIndex()
        valueCallbacks.updateValue(callback, forKey: nextIndex)
        send(command: LineFollowerCommand(index: UInt8(nextIndex), port: port))
    }
    
    @objc private func onReceivedData(_ data: Data) {
        //        if let data = notification.object as? Data {
        parser.addReceived(data: data)
        //        }
    }
    
    private func getNextIndex() -> Int {
        let index = self.index
        self.index += 1
        if self.index >= 255 {
            self.index = 128
        }
        return index
    }
    
    private func send(command: MakeblockCommand) {
        if let pr = manager.connectedDevice {
            //            pr.send(res: command.data, to: pr)
            manager.send(res: command.data, to: pr)
        }
    }
}

extension MBot: DataParserDelegate {
    public func onParseData(_ data: Data) {
        interpreter.interpreter(data: data) { (index, value) in
            if let callback = valueCallbacks[index] {
                callback(value)
            }
        }
    }
    
    public func onParseErrorData(_ data: Data) { }
    
    public func onBufferOverflow(length: Int) { }
}
