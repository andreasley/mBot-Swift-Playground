//
//  PageHelper.swift
//  spheroArcade
//
//  Created by Anthony Blackman on 2017-03-16.
//  Copyright © 2017 Sphero Inc. All rights reserved.
//
// Helper functions to abstract out differences between running in playgrounds app and as an iOS app.


import Foundation
import PlaygroundSupport
import UIKit

/// Waits for a number of seconds before running the next sequence of code.
///
/// - Parameter seconds: the number of seconds to wait
public func sleep(_ seconds: Double) {
    usleep(UInt32(seconds * 1e6))
}

public var currentProxy: PlaygroundRemoteLiveViewProxy? {
    return PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy
}

public func Log(_ text: String, _ index: Int = 0) {
    Loader.currentLiveViewController().addConnectButton(text)
}

public func setProxyDelegate(_ delegate: PlaygroundRemoteLiveViewProxyDelegate) {
    if let proxy = currentProxy {
        proxy.delegate = delegate
    }
}

public func sendToLiveView(_ value: PlaygroundValue) {
    if let proxy = currentProxy {
        proxy.send(value)
    }
}

public func sendToContents(_ value: PlaygroundValue) {
    if let proxy = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler {
        proxy.send(value)
    }
}

public func sendToContentsWithEnum(_ enumValue: SPCallbackCommand) {
    sendToContents(enumValue.value)
}

public struct Utils {
    public static func testLog(_ items: CustomStringConvertible...) {
        if let vc = PlaygroundPage.current.liveView as? LiveViewController {
            let label = UILabel.init(frame: vc.view.bounds)
            vc.view.addSubview(label)
            label.textColor = UIColor.blue
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = items.description
        }
    }
}


public extension PlaygroundValue {
    
    public func arrayValue(_ key: String? = nil) -> [PlaygroundValue]? {
        if let pv = spValue(key), case let .array(f) = pv {
            return f
        } else {
            if case let .array(f) = self {
                return f
            }
        }
        return nil
    }
    
    public func dictValue(_ key: String? = nil) -> [String: PlaygroundValue]? {
        if let pv = spValue(key), case let .dictionary(f) = pv {
            return f
        } else {
            if case let .dictionary(f) = self {
                return f
            }
        }
        return nil
    }
    
    public func floatValue(_ key: String? = nil) -> Float? {
        if let pv = spValue(key), case let .floatingPoint(f) = pv {
            return Float(f)
        } else {
            if case let .floatingPoint(f) = self {
                return Float(f)
            }
        }
        return nil
    }
    
    public func intValue(_ key: String? = nil) -> Int? {
        if let pv = spValue(key), case let .integer(f) = pv {
            return Int(f)
        } else {
            if case let .integer(f) = self {
                return Int(f)
            }
        }
        return nil
    }
    
    public func boolValue(_ key: String? = nil) -> Bool? {
        if let pv = spValue(key), case let .boolean(f) = pv {
            return Bool(f)
        } else {
            if case let .boolean(f) = self {
                return Bool(f)
            }
        }
        return nil
    }
    
    public func stringValue(_ key: String? = nil) -> String? {
        if let pv = spValue(key), case let .string(f) = pv {
            return f
        } else {
            if case let .string(f) = self {
                return f
            }
        }
        return nil
    }
    
    public func spValue(_ key: String? = nil) -> PlaygroundValue? {
        if let k = key, case let .dictionary(d) = self, let v = d[k] {
            return v
        }
        return self
    }
    
}
