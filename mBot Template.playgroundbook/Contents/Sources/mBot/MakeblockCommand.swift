//
//  MakeblockCommand.swift
//  Test
//
//  Created by CatchZeng on 2017/7/4.
//  Copyright © 2017年 catch. All rights reserved.
//

import Foundation

public protocol MakeblockCommand {
    var data: Data { get }
}

public protocol RJ25Command : MakeblockCommand {
    var index: UInt8 { get }
    var action: RJ25Action { get }
    var device: RJ25DeviceID? { get }
    var port: RJ25Port? { get }
    var slot: RJ25Slot? { get }
    var subCommand: UInt8? { get }
    var mode: UInt8? { get }
    var payload: [UInt8]? { get }
    var prefixA: UInt8 { get }
    var prefixB: UInt8 { get }
    var suffixA: UInt8 { get }
    var suffixB: UInt8 { get }
}

extension RJ25Command {
    public var index: UInt8 { return 0x00 }
    
    public var action: RJ25Action { return .write }
    
    public var device: RJ25DeviceID? { return nil }
    
    public var port: RJ25Port? { return nil }
    
    public var slot: RJ25Slot? { return nil }
    
    public var subCommand: UInt8? { return nil }
    
    public var mode: UInt8? { return nil }
    
    public var payload: [UInt8]? { return nil }
    
    public var prefixA: UInt8 { return 0xff }
    
    public var prefixB: UInt8 { return 0x55 }
    
    public var suffixA: UInt8 { return 0x0d }
    
    public var suffixB: UInt8 { return 0x0a }
}

extension RJ25Command {
    public var data: Data {
        var length = 2//index&action
        var bytes: [UInt8] = [prefixA, prefixB, index, action.rawValue]
        
        if let device = device {
            length += 1
            bytes.append(device.rawValue)
        }
        if let port = port {
            length += 1
            bytes.append(port.rawValue)
        }
        if let slot = slot {
            length += 1
            bytes.append(slot.rawValue)
        }
        if let subCommand = subCommand {
            length += 1
            bytes.append(subCommand)
        }
        if let mode = mode {
            length += 1
            bytes.append(mode)
        }
        if let payload = payload {
            length += payload.count
            for byte in payload {
                bytes.append(byte)
            }
        }
        
        bytes.insert(UInt8(length), at: 2)
        
        return Data(bytes: bytes)
    }
    
    public func intToUInt8Bytes(_ value: Int) -> (UInt8, UInt8) {
        let lowValue = UInt8(value & 0xff)
        let highValue = UInt8((value >> 8) & 0xff)
        return (lowValue, highValue)
    }
}

public struct VersionCommand: RJ25Command {
    public var action: RJ25Action { return .read }
    
    public var device: RJ25DeviceID? { return .version }
}

public struct BoardLEDCommand: RJ25Command {
    private var _payload: [UInt8]?
    private var _port: RJ25Port
    
    init(position: RGBLEDPosition = .all,
         red: Int,
         green: Int,
         blue: Int,
         brightness: Float = 0.5,
         port: RJ25Port = .rgbLED) {
        
        _port = port
        let redValue = Float(red)*brightness
        let greenValue = Float(green)*brightness
        let blueValue = Float(blue)*brightness
        _payload = [position.rawValue, UInt8(redValue), UInt8(greenValue), UInt8(blueValue)]
    }
    
    public var device: RJ25DeviceID? { return .rgbLED }
    
    public var port: RJ25Port? { return _port }
    
    public var slot: RJ25Slot? { return .slot2 }
    
    public var payload: [UInt8]? { return _payload }
}

public struct DCMotorCommand: RJ25Command {
    private var _payload: [UInt8]?
    private var _port: RJ25Port
    init(port: RJ25Port, speed: Int) {
        _port = port
        let speedValue = (port == .motor1) ? -speed : speed
        let (low, high) = intToUInt8Bytes(speedValue)
        _payload = [low, high]
    }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.dcMotor }
    
    public var port: RJ25Port? { return _port }
    
    public var payload: [UInt8]? { return _payload }
}

public struct BuzzerCommand: RJ25Command {
    var duration: MusicNoteDuration
    var pitch: MusicNotePitch
    var beat: Double
    private var _payload: [UInt8]?
    
    init(pitch: MusicNotePitch, duration: MusicNoteDuration, beat: Double = 1.0) {
        self.duration = duration
        self.pitch = pitch
        self.beat = beat
        let finalDuration = Double(duration.rawValue) * beat
        let (pitchLow, pitchHigh) = intToUInt8Bytes(pitch.rawValue)
        let (durationLow, durationHigh) = intToUInt8Bytes(Int(finalDuration))
        _payload = [pitchLow, pitchHigh, durationLow, durationHigh]
    }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.buzzer }
    
    public var payload: [UInt8]? { return _payload }
}

public struct JoystickCommand: RJ25Command {
    var leftSpeed: Int
    var rightspeed: Int
    private var _payload: [UInt8]?
    
    init(leftSpeed: Int, rightspeed: Int) {
        self.leftSpeed = leftSpeed
        self.rightspeed = rightspeed
        let (lowLeft, highLeft) = intToUInt8Bytes(-leftSpeed)
        let (lowRight, highRight) = intToUInt8Bytes(rightspeed)
        _payload = [lowLeft, highLeft, lowRight, highRight]
    }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.joystick }
    
    public var payload: [UInt8]? { return _payload }
}

public struct UltraSonicCommand: RJ25Command {
    var _index: UInt8
    private var _port: RJ25Port
    
    init(index: UInt8, port: RJ25Port = .port3) {
        _index = index
        _port = port
    }
    
    public var action: RJ25Action { return .read }
    
    public var index: UInt8 { return _index }
    
    public var port: RJ25Port? { return _port }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.ultrasonicSensor }
}

public struct LineFollowerCommand: RJ25Command {
    var _index: UInt8
    private var _port: RJ25Port
    
    init(index: UInt8, port: RJ25Port = .port2) {
        _index = index
        _port = port
    }
    
    public var action: RJ25Action { return .read }
    
    public var index: UInt8 { return _index }
    
    public var port: RJ25Port? { return _port }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.lineFollowerSensor }
}

public struct lightnessCommand: RJ25Command {
    var _index: UInt8
    private var _port: RJ25Port
    
    init(index: UInt8, port: RJ25Port = .port6) {
        _index = index
        _port = port
    }
    
    public var action: RJ25Action { return .read }
    
    public var index: UInt8 { return _index }
    
    public var port: RJ25Port? { return _port }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.lightnessSensor }
}

public struct InfraredSendCommand: RJ25Command {
    var mIndex: UInt8
    private var mPayload: [UInt8]?
    
    init(index: UInt8 = 0x00, msg: String) {
        mIndex = index
        mPayload = msg.bytes
    }
    
    public var action: RJ25Action { return .write }
    
    public var index: UInt8 { return mIndex }
    
    public var device: RJ25DeviceID? { return RJ25DeviceID.infraredSensor }
    
    public var payload: [UInt8]? { return mPayload }
}
