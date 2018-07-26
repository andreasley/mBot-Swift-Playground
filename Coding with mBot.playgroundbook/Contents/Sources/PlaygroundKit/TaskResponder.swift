//
//  TaskResponder.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/18.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import CoreBluetooth
import SceneKit

public protocol TaskResponder {
    associatedtype Command: SPCommand
    var command: Command {get set}
    func respondTo(_ command: Command)
    func stop()
    init(command: Command)
}

public enum TT: Int {
    case a = 0
    case b = 1
    
}

extension TaskResponder {
    func execeute(finished: ((Bool)->())) {
        respondTo(command)
        finished(true)
    }
}


public class BLETaskResponder: TaskResponder {

    public typealias Command = MCommand
    public var command: Command
    var finishAction: ((AnyObject)->())? = nil
    
    required public init(command: Command) {
        self.command = command
    }
    
    fileprivate var scene: SCNScene!
    fileprivate let bot: MBot = MBot()
    private var timers: [Timer] = []
    public func respondTo(_ command: MCommand) {
        switch command.target {
        case .engine(let dir):
            if case let .moveEngine(l, r) = command.action {
                rollWheel(dir, leftSpeed: l, right: r)
            }
        case .led(let id):
            if case let .turnLED(color) = command.action {
                turnLed(id: id, color: color)
            }
        case .buzzer:
            if case let .sound(tone) = command.action {
                sound(tone.pitch, tone.meter)
            }
        case .ultrasonicSensor(let port):
            detectUltrasonic(port)
        case .lineSenor(let port):
            detectLineSenor(port)
        case .lightSensor(let port):
            detectLightSensor(port)
        case .infraredSensor(let text):
            sendInfraredMessage(text)
        default:
            print("Default Action")
        }
    }
    
    func detectLineSenor(_ port: Int) {
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                Loader.currentBot.getLineFollower(self.getPort(port)) { value in
                    sendToContentsWithEnum(.lineSign(Int(value)))
            }
        }
        timers.append(timer)
    }
    
    func detectUltrasonic(_ port: Int) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                Loader.currentBot.getUltraSonic(self.getPort(port)) { value in
                    sendToContentsWithEnum(.ultrasonic(value))
            }
        }
        timers.append(timer)
    }
    
    func detectLightSensor(_ port: Int) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                Loader.currentBot.getLightness(self.getPort(port)) { value in
                    sendToContentsWithEnum(.light(value))
                }
        }
        timers.append(timer)
    }
    
    func sendInfraredMessage(_ message: String) {
        Loader.currentBot.sendInfraredMessage(message)
    }

    
    func sound(_ tone: Int, _ meter: Int) {
        if let p = MusicNotePitch.init(intValue: tone), let m = MusicNoteDuration.init(intValue: meter) {
            Loader.currentBot.setBuzzer(pitch: p, duration: m)
        }
    }
    
    public func stop() {
        switch self.command.target {
        case .engine:
            self.rollWheel(.both, leftSpeed: 0, right: 0)
        case .led(let id):
            self.turnLed(id: id, color: .off)
        default:
            print("Default Action")
        }
        
    }
    
    public func stopAll() {
        timers.forEach { timer in
                timer.invalidate()
        }
        timers.removeAll()
        Loader.currentBot.setDCMotor(leftSpeed: 0, rightSpeed: 0)
    }
    
    func turnLed(id: String, color: Color) {
        var position: RGBLEDPosition!
        switch id {
        case "0":
            position = .left
        case "1":
            position = .right
        case "2":
            position = .all
        default:
            position = .all
        }
        Loader.currentBot.setLed(position: position, red: Int(color.rgb.R * 255), green: Int(color.rgb.G * 255), blue: Int(color.rgb.B * 255))

    }
    
    func rollWheel(_ direction: SPCommandTarget.Direction, leftSpeed: Float, right: Float) {
        switch direction {
        case .left:
            Loader.currentBot.setDCMotor(leftSpeed: Int(leftSpeed), rightSpeed: 0)
        case .right:
            Loader.currentBot.setDCMotor(leftSpeed: 0, rightSpeed: Int(right))
        case .both:
            Loader.currentBot.setDCMotor(leftSpeed: Int(leftSpeed), rightSpeed: Int(right))
        }
    }

    //MARK: Private
    func getPort(_ value: Int) -> RJ25Port {
        switch value {
        case 1:
            return .port1
        case 2:
            return .port2
        case 3:
            return .port3
        case 4:
            return .port4
        case 6:
            return .port6
        case 7:
            return .rgbLED
        case 9:
            return .motor1
        case 10:
            return .motor2
        default:
            return .port1
        }
    }
}


public class SCNTaskResponder: TaskResponder {
    
    public typealias Command = MCommand
    var scene: SCNScene!
    public var command: Command
    var finishAction: ((Bool)->())? = nil
    
    required public init(command: Command) {
        self.command = command
        scene = Loader.currentScene()!
    }
    
    public func respondTo(_ command: MCommand) {
        print(Date())
        switch command.target {
        case .engine(let dir):
            if case let .moveEngine(l, r) = command.action {
                rollWheel(dir, leftSpeed: CGFloat(l), right: CGFloat(r))
            }
        case .led(let id):
            if case let .turnLED(color) = command.action {
                turnLed(id: id, color: color)
            }
        case .buzzer:
            sound()
        case .earth:
            if case let .rotate(by, angle, _) = command.action {
                if angle > 0 {
                    roll(name: "Earth", by: by, speed: 1)
                } else {
                    stop()
                }
            }
        case .testText(let t):
            Log(t)
            
        default:
            print("respondTo Default Action")
        }
    }
    
    func sound() {
        
        
    }
    
    public func stop() {
        switch self.command.target {
        case .engine:
            rollWheel(.both, leftSpeed: 0, right: 0)
        case .led(let id):
            turnLed(id: id, color: .off)
        case .earth:
            roll(name: "Earth", by: SCNVector3(), speed: 0)
        default:
            print("Default Action")
        }
        
    }
    
    public func stopAll() {
        guard let scene = Loader.currentScene() else {
            return
        }
        if let itemNode = scene.rootNode.childNode(withName: "Earth", recursively: true) {
            itemNode.removeAllActions()
        }
        if let itemNode = scene.rootNode.childNode(withName: "wheel__01", recursively: true) {
            itemNode.removeAllActions()
        }
        if let itemNode = scene.rootNode.childNode(withName: "wheel__02", recursively: true) {
            itemNode.removeAllActions()
        }
        
    }
    
    func turnLed(id: String, color: Color) {
        var bool = false
        if color == Color.off {
            bool = true
        }
        switch id {
        case "0":
            switchLED(name: "light__01", color: color, off: bool)
        case "1":
            switchLED(name: "light__02", color: color, off: bool)
        case "2":
            switchLED(name: "light__01", color: color, off: bool)
            switchLED(name: "light__02", color: color, off: bool)
        default:
            break
        }
        
    }
    
    func switchLED(name: String, color: Color, off: Bool) {
        guard let itemNode = scene.rootNode.childNode(withName: name, recursively: true), let light = itemNode.light else {
            return
        }
        if off == true {
            light.color = UIColor.black
        } else {
            light.color = UIColor.init(red: CGFloat(color.rgb.R), green: CGFloat(color.rgb.G), blue: CGFloat(color.rgb.B), alpha: 1)
        }
    }
    
    func rollWheel(_ direction: SPCommandTarget.Direction, leftSpeed: CGFloat, right: CGFloat) {
        switch direction {
        case .left:
            rollWheel(name: "wheel__01", speed: leftSpeed)
        case .right:
            rollWheel(name: "wheel__02", speed: right)
        case .both:
            rollWheel(name: "wheel__01", speed: leftSpeed)
            rollWheel(name: "wheel__02", speed: right)
        }
        
    }
    
    func rollWheel(name: String, speed: CGFloat = 25) {
        roll(name: name, byAxis: 0, speed: speed)
    }
    
    func roll(name: String, byAxis: Int = 0, speed: CGFloat = 25) {
        var axis = (0, 0, 1)
        switch byAxis {
        case 0: break
        case 1:
            axis = (0, 1, 0)
        case 2:
            axis = (1, 0, 0)
        default: break
        }
        var vector = SCNVector3.init(axis.0, axis.1, axis.2)
        if speed < 0 {
            vector = SCNVector3.init(-axis.0, -axis.1, -axis.2)
        }
        roll(name: name, by: vector, speed: speed)
    }
    
    func roll(name: String, by vector: SCNVector3, speed: CGFloat ) {
        if let itemNode = scene.rootNode.childNode(withName: name, recursively: true) {
            itemNode.removeAllActions()
            guard speed != 0 else {
                return
            }
            let action = SCNAction.repeatForever(SCNAction.repeat(SCNAction.rotateBy(x: CGFloat(vector.x), y: CGFloat(vector.y), z: CGFloat(vector.z), duration: 1), count: 1))
            action.speed = fabs(speed)
            itemNode.runAction(action)
        }
    }
    
    
}
