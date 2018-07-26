//
//  MBotWorld.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/21.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import SceneKit
let bot = MBot()
public class MBotService {
    static public func testText(_ text: String) {
        let command = MCommand.init(target: .testText(text), action: .execute, duration: 0, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command], duration: 0.05)
        Loader.sharedTaskMgr.addTasks([task])
    }
    
    static public func wait(_ duration: Float) {
        let command = MCommand.init(target: .none, action: .execute, duration: duration, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command], duration: duration)
        Loader.sharedTaskMgr.addTasks([task])
    }
    
    static public func moveForward(speed: Float) {
        moveEngine(leftSpeed: speed, rightSpeed: speed)
    }
    
    static public func moveBackward(speed: Float) {
        moveEngine(leftSpeed: -speed, rightSpeed: -speed)
    }
    
    static public func moveLeft(speed: Float) {
        moveEngine(leftSpeed: -speed, rightSpeed: speed)
    }
    
    static public func moveRight(speed: Float) {
        moveEngine(leftSpeed: speed, rightSpeed: -speed)
    }
    
    static public func moveEngine(leftSpeed: Float, rightSpeed: Float) {
        let left: Float = leftSpeed
        let right: Float = rightSpeed
        var earthVector = SCNVector3.init(-1, 0, 0)
        switch (leftSpeed, rightSpeed) {
        case (0..<1000, 0..<1000):
            earthVector = SCNVector3.init(0, 0, -1)
        case (-1000..<0, -1000..<0):
            earthVector = SCNVector3.init(0, 0, 1)
        case (-1000..<0, 0..<1000):
//            earthVector = SCNVector3.init(1, 0, 0)
            earthVector = SCNVector3.init(0, 0, 1)
        case (0..<1000, -1000..<0):
//            earthVector = SCNVector3.init(-1, 0, 0)
            earthVector = SCNVector3.init(0, 0, -1)
        default:
            earthVector = SCNVector3.init(0, 0, 1)
        }
        var earthAngle: Float = 1
        if leftSpeed == 0 && rightSpeed == 0 {
            earthAngle = 0
        }
        let command = MCommand.init(target: .engine(.both), action: .moveEngine(leftSpeed: left, right: right), duration: 0, platform: .all)
        let commandEarth = MCommand.init(target: .earth, action: .rotate(by: earthVector, angle: earthAngle, duration: 0), duration: 0, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command, commandEarth], duration: 0.05)
        Loader.sharedTaskMgr.addTasks([task])
    }
    
    static public func stop() {
        moveEngine(leftSpeed: 0, rightSpeed: 0)
    }
    
    static public func playSound(tone: Int, meter: Int) {
        let duration = Float(meter / 1000) * 2 + 0.2

        let command = MCommand.init(target: .buzzer, action: .sound(Tone.init(pitch: tone, meter: meter)), duration: duration, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command], duration: duration)
        Loader.sharedTaskMgr.addTasks([task])
    }
    
    static public func turnLED(_ item: Int, color: UIColor) {
        if let colors = color.cgColor.components {
            let command = MCommand.init(target: .led(String(item)), action: .turnLED(color: Color.init(rgb: (Float(colors[0]), Float(colors[1]), Float(colors[2])), alpha: Float(colors[3]))), duration: 0, platform: .all)
            let task = SPTask<MCommand>.init(commands: [command], duration: 0.05)
            Loader.sharedTaskMgr.addTasks([task])
        }
    }
    
    static public func detectLineSenor(at port: Int, callback: @escaping (Int)->()) {
        contentListenr.lineSignCallBack = callback
        let command = MCommand.init(target: .lineSenor(port), action: .execute, duration: 0, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command], duration: 0.05)
        Loader.sharedTaskMgr.addTasks([task])
    }
    
    static public func detectUltrasonic(at port: Int, callback: @escaping (Float)->()) {
        contentListenr.ultrasonicCallBack = callback
        let command = MCommand.init(target: .ultrasonicSensor(port), action: .execute, duration: 0, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command], duration: 0.05)
        Loader.sharedTaskMgr.addTasks([task])
    }

    static public func detectLightSensor(callback: @escaping (Float)->()) {
        contentListenr.lightCallBack = callback
        let command = MCommand.init(target: .lightSensor(6), action: .execute, duration: 0, platform: .all)
        let task = SPTask<MCommand>.init(commands: [command], duration: 0.05)
        Loader.sharedTaskMgr.addTasks([task])
    }

    static public func sendInfraredMessage(_ message: String) {
        let command = MCommand.init(target: .infraredSensor(message), action: .execute, duration: 0, platform: .bluetooth)
        let task = SPTask<MCommand>.init(commands: [command], duration: 0.05)
        Loader.sharedTaskMgr.addTasks([task])
    }
    
    static public func sendTasks() {
        Loader.sharedTaskMgr.sendTasks()
    }
}


