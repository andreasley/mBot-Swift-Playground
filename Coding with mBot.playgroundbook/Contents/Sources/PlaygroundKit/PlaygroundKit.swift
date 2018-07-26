//
//  PlaygroundKit.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/12.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import SceneKit
import PlaygroundSupport

public struct Color: SPMessageConstructible, Equatable {
    public static func ==(lhs: Color, rhs: Color) -> Bool {
        return lhs.alpha == rhs.alpha && lhs.rgb == rhs.rgb
    }
    var rgb: (R: Float, G: Float, B: Float) = (0, 0, 0)
    var alpha: Float = 0
    public var value: PlaygroundValue {
        return .dictionary(["R": rgb.R.value, "G": rgb.G.value, "B": rgb.B.value, "alpha": alpha.value])
    }
    
    static public let red = Color.init(rgb: (255, 0, 0))
    static public let orange = Color.init(rgb: (230, 165, 25))
    static public let yellow = Color.init(rgb: (255, 255, 0))
    static public let green = Color.init(rgb: (0, 255, 0))
    static public let blue = Color.init(rgb: (0, 0, 255))
    static public let cyan = Color.init(rgb: (20, 166, 255))
    static public let purple = Color.init(rgb: (255, 0, 255))
    static public let off = Color.init(rgb: (0, 0, 0), alpha: 0)
    
    public init(rgb: (R: Float, G: Float, B: Float), alpha: Float = 1) {
        self.rgb = rgb
        self.alpha = alpha
    }
    
    public init?(_ value: PlaygroundValue) {
        guard case let .dictionary(dict) = value else {
            return nil
        }
        guard let r = dict["R"], let g = dict["G"], let b = dict["B"], let a = dict["alpha"] else {
            return nil
        }
        guard case let .floatingPoint(red) = r, case let .floatingPoint(green) = g, case let .floatingPoint(blue) = b, case let .floatingPoint(alpha) = a else {
            return nil
        }
        self.rgb = (Float(red), Float(green), Float(blue))
        self.alpha = Float(alpha)
    }
}

// MARK: SPMessageConstructor

public protocol SPMessageConstructor {
    var value: PlaygroundValue { get }
}

public protocol SPMessageConstructible: SPMessageConstructor {
    init?(_ value: PlaygroundValue)
}

// MARK: SPMessageConstructible Extensions

extension String: SPMessageConstructor {
    public var value: PlaygroundValue {
        return .string(self)
    }
}

extension SCNVector3: SPMessageConstructible, Equatable {
    
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    public var value: PlaygroundValue {
        let x: PlaygroundValue = .floatingPoint(Double(self.x))
        let y: PlaygroundValue = .floatingPoint(Double(self.y))
        let z: PlaygroundValue = .floatingPoint(Double(self.z))
        return .array([x, y, z])
    }
    
    public init?(_ value: PlaygroundValue) {
        guard case let .array(components) = value, components.count == 3 else { return nil }
        guard case let .floatingPoint(xd) = components[0],
            case let .floatingPoint(yd) = components[1],
            case let .floatingPoint(zd) = components[2] else { return nil }
        
        self = SCNVector3(x: SCNFloat(xd), y: SCNFloat(yd), z: SCNFloat(zd))
    }
}

extension SCNFloat: SPMessageConstructible {
    public var value: PlaygroundValue {
        return .floatingPoint(Double(self))
    }
    
    public init?(_ value: PlaygroundValue) {
        guard case let .floatingPoint(value) = value else { return nil }
        self = SCNFloat(value)
    }
}

extension Bool: SPMessageConstructible {
    public var value: PlaygroundValue {
        return .boolean(self)
    }
    
    public init?(_ value: PlaygroundValue) {
        guard case let .boolean(value) = value else { return nil }
        self = value
    }
}

extension Int: SPMessageConstructible {
    public var value: PlaygroundValue {
        return .integer(self)
    }
    
    public init?(_ value: PlaygroundValue) {
        guard case let .integer(value) = value else { return nil }
        
        self = value
    }
}
