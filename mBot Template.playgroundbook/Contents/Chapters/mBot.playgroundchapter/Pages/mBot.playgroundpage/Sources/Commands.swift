//
//  Commands.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//
/**
 Turns the character left.
 */
import PlaygroundSupport
import SceneKit

public var half = MusicNoteDuration.half

public var ultrasonic: Float {
    return contentListenr.ultrasonic
}

public var light: Float {
    return contentListenr.light
}

public var line: Int {
    return contentListenr.lineSign
}

public func testText(_ text: String) {
    MBotService.testText("\(text)")
}

public func moveLeft(speed: Float) {
    MBotService.moveLeft(speed: speed)
}

public func moveRight(speed: Float) {
    MBotService.moveRight(speed: speed)
}

public func moveForward(speed: Float) {
    MBotService.moveForward(speed: speed)
}

public func moveBackward(speed: Float) {
    MBotService.moveBackward(speed: speed)
}

public func stop() {
    MBotService.moveEngine(leftSpeed: 0, rightSpeed: 0)
}

public func turnLED(item: Int, color: UIColor) {
    MBotService.turnLED(item, color: color)
}

public func playSound(tone: MusicNotePitch, meter: MusicNoteDuration) {
    MBotService.playSound(tone: tone.rawValue, meter: meter.rawValue)
}

public func detectLineSenor(port: Int, callback: @escaping (Int)->()) {
    MBotService.detectLineSenor(at: port, callback: callback)
}

public func detectUltrasonic(port: Int, callback: @escaping (Float)->()) {
    MBotService.detectUltrasonic(at: port, callback: callback)
}

public func detectLightSensor(callback: @escaping (Float)->()) {
    MBotService.detectLightSensor(callback: callback)
}

public func sendInfraredMessage(message: String) {
    MBotService.sendInfraredMessage(message)
}

public func wait(duration: Float) {
    MBotService.wait(duration)
}

public func startEngine(leftSpeed: Float, rightSpeed: Float) {
    MBotService.moveEngine(leftSpeed: leftSpeed, rightSpeed: rightSpeed)
}
