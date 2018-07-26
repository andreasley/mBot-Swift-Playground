//
//  SPMBot.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/21.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import PlaygroundSupport

public typealias FloatCallback = ((Float) -> ())
public typealias BoolCallback = ((Bool) -> ())
public typealias IntCallback = ((Int) -> ())


public class ContentListenr: PlaygroundRemoteLiveViewProxyDelegate {
    public var light: Float = 0
    public var lineSign: Int = 0
    public var ultrasonic: Float = 400
    public var isConnected: Bool = false
    
    public var ultrasonicCallBack: FloatCallback? = nil
    public var lightCallBack: FloatCallback? = nil
    public var isConnectedCallBack: BoolCallback? = nil
    public var lineSignCallBack: IntCallback? = nil
    public init() {}
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        guard let type = message.stringValue(CallbackEncodingKey.typeKey), let value = message.spValue(CallbackEncodingKey.valueKey) else {
            return
        }
        switch type {
        case CallbackEncodingKey.light:
            if let f = value.floatValue() {
                self.light = f
            }
        case CallbackEncodingKey.lineSign:
            if let f = value.intValue() {
                self.lineSign = f
            }
        case CallbackEncodingKey.ultrasonic:
            if let f = value.floatValue() {
                self.ultrasonic = f
            }
        case CallbackEncodingKey.isConnected:
            if let f = value.boolValue(), let c = isConnectedCallBack {
                c(f)
            }
        default:
            break
        }
    }

    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        PlaygroundPage.current.finishExecution()
    }

}




