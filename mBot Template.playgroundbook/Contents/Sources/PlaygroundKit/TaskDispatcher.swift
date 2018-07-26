//
//  Dispatcher.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/21.
//  Copyright © 2017年 block Make. All rights reserved.
//

import Foundation
import SceneKit
import PlaygroundSupport

public class SPDispatcher {
    public var isConnectedWithContents = true
    var currentIndex: Int = 0
    var tasks: [SPTask<MCommand>] = []

    let bleResponder = BLETaskResponder.init(command: MCommand())
    let scnResponder = SCNTaskResponder.init(command: MCommand())
    
    func handleTasks(tasks: [SPTask<MCommand>]) {
        self.tasks.append(contentsOf: tasks)
        handleNext()
    }
    
    func handleNext() {
        guard isConnectedWithContents == true else {
            return
        }
        if currentIndex < tasks.count {
            let task = tasks[currentIndex]
            if task.state == .incomplete {
                task.commands.forEach({ (cmd) in
                    self.handleCommand(cmd)
                })
                self.currentIndex += 1
                guard currentIndex < tasks.count else {
                    return
                }
                let delayTime: DispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(50) + DispatchTimeInterval.milliseconds(Int(task.duration * 1000))
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    guard self.isConnectedWithContents == true, self.currentIndex < self.tasks.count else {
                        return
                    }
                    self.handleNext();
                }
            }
        } else {
            currentIndex = 0
            tasks.removeAll()
        }
    }
    
    public func start() {
        tasks.removeAll()
        currentIndex = 0
        self.isConnectedWithContents = true
        Log("start currentIndex\(currentIndex), tasks\(tasks.count)")
    }
    
    public func stop() {
        self.isConnectedWithContents = false
        bleResponder.stopAll()
        scnResponder.stopAll()
        tasks.removeAll()
        currentIndex = 0
        Log("stop currentIndex\(currentIndex), tasks\(tasks.count)")

    }
    
    private func handleCommand(_ msg: MCommand) {
        switch msg.platform {
        case .bluetooth:
            bleResponder.command = msg
            bleResponder.execeute(finished: { _ in
                
            })
        case .sceneKit:
            scnResponder.command = msg
            scnResponder.execeute(finished: { _ in
                
            })
        case .all:
            bleResponder.command = msg
            bleResponder.execeute(finished: { _ in
                
            })
            scnResponder.command = msg
            scnResponder.execeute(finished: { _ in
                
            })
        }
    }
    //MARK: Delegate
    public func receive(_ message: PlaygroundValue) {
        if case let .array(tasks) = message {
            var final: [SPTask<MCommand>] = []
            tasks.forEach({ (v) in
                if let t = SPTask<MCommand>.init(v) {
                    final.append(t)
                }
            })
            self.handleTasks(tasks: final)
        }
    }

}
