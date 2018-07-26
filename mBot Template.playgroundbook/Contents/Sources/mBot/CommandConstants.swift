//
//  CommandConstants.swift
//  Test
//
//  Created by CatchZeng on 2017/7/4.
//  Copyright © 2017年 catch. All rights reserved.
//

import Foundation



public enum RJ25Action: UInt8 {
    case read = 0x01
    case write = 0x02
}

public enum RJ25DeviceID: UInt8 {
    case version = 0x00
    case joystick = 0x05
    case dcMotor = 0x0a
    case rgbLED = 0x08
    case buzzer = 0x22
    case ultrasonicSensor = 0x01
    case lightnessSensor = 0x03
    case lineFollowerSensor = 0x11
    case infraredSensor = 0x0d
}

public enum RJ25Port: UInt8 {
    case board = 0x00
    case port1 = 0x01
    case port2 = 0x02
    case port3 = 0x03
    case port4 = 0x04
    case port6 = 0x06
    case rgbLED = 0x07
    case motor1 = 0x09
    case motor2 = 0x0a
}

public enum RJ25Slot: UInt8 {
    case slot1 = 0x01
    case slot2 = 0x02
}

public enum RGBLEDPosition: UInt8 {
    case all = 0
    case left = 1
    case right = 2
}

public enum RGBLEDColor: UInt8 {
    case red = 0
    case orange
    case yellow
}

public enum MusicNotePitch: Int {
    case zero = 0
    case c2 = 65
    case d2 = 73
    case e2 = 82
    case f2 = 87
    case g2 = 98
    case a2 = 110
    case b2 = 123
    case c3 = 131
    case d3 = 147
    case e3 = 165
    case f3 = 175
    case g3 = 196
    case a3 = 220
    case b3 = 247
    case c4 = 262
    case d4 = 294
    case e4 = 330
    case f4 = 349
    case g4 = 392
    case a4 = 440
    case b4 = 494
    case c5 = 523
    case d5 = 587
    case e5 = 658
    case f5 = 698
    case g5 = 784
    case a5 = 880
    case b5 = 988
    case c6 = 1047
    case d6 = 1175
    case e6 = 1319
    case f6 = 1397
    case g6 = 1568
    case a6 = 1760
    case b6 = 1976
    case c7 = 2093
    case d7 = 2349
    case e7 = 2637
    case f7 = 2794
    case g7 = 3136
    case a7 = 3520
    case b7 = 3951
    case c8 = 4186
    case l1 = 555
    case l2 = 623
    case l3 = 741
    case l4 = 832
    case l5 = 934
    
    public init?(intValue: Int) {
        if let a = MusicNotePitch.init(rawValue: intValue) {
            self = a
        } else {
            return nil
        }
    }
}

public enum MusicNoteDuration: Int {
    case whole = 1000
    case half = 500
    case quarter = 250
    case eighth = 125
    case sixteenth = 62
    public init?(intValue: Int) {
        if let a = MusicNoteDuration.init(rawValue: intValue) {
            self = a
        } else {
            return nil
        }
    }
}
