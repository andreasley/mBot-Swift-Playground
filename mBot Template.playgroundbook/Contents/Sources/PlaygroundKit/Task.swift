//
//  Task.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/12.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import PlaygroundSupport
import SceneKit
import UIKit

public protocol SPTaskDelegate: class {
    func manager<Command>(didPerformTask: SPTask<Command>)
}

public final class SPTaskManager<Command: SPCommand> {
    var currentIndex = 0
    public var delegate: SPTaskDelegate?
    var tasks: [SPTask<Command>] = []
    var time: TimeInterval = -1
    public init(delegate: SPTaskDelegate? = nil) {
        self.delegate = delegate
    }
    public func addTasks(_ tasks: [SPTask<Command>]) {
        self.tasks.append(contentsOf: tasks)
        sendTasks()
    }
    
    public func sendTasks() {
        if let proxy = currentProxy {
            guard tasks.count > 0 else {
                return
            }
            let arrayValue = tasks.map { (task) -> PlaygroundValue in
                return task.value
            }
            proxy.send(.array(arrayValue))
            
            let time = tasks.reduce(0, { (r, ele) -> Float in
                return Float(r) + ele.duration
            })
            usleep(UInt32(time * 1e6))
            tasks.removeAll()
        }
        
    }
    
}

public final class SPTask<Command: SPCommand>: SPMessageConstructor {
    public var value: PlaygroundValue {
        return .dictionary(["commands": .array(commands.map{$0.value}), "duration": duration.value, "state": state.value])
    }
    
    init?(_ value: PlaygroundValue) {
        guard case let .dictionary(dict) = value, let v =  dict["commands"], case let .array(values) = v else {
            return nil
        }
        guard let d = dict["duration"], case let .floatingPoint(duration) = d, let s = dict["state"], let state = State.init(s) else {
            return nil
        }
        self.duration = Float(duration)
        self.state = state
        self.commands = values.map {Command.init($0)!}
    }
    
    public enum State: Int, SPMessageConstructor {
        case incomplete = 0
        case performing
        case complete
        init?(_ value: PlaygroundValue) {
            guard case let .integer(v) = value, let a = State.init(rawValue: v) else {
                return nil
            }
            self = a
        }
        
        public var value: PlaygroundValue {
            return .integer(rawValue)
        }
    }
    
    var commands: [Command]
    
    var duration: Float = 0
    
    private(set) var state: State = .incomplete
    
    public init(commands: [Command], duration: Float = 0) {
        self.commands = commands
        self.duration = duration
    }
    
}
