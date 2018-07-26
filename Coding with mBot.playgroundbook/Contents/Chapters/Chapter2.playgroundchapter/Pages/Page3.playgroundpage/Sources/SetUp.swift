//
//  Setup.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//
import Foundation
import PlaygroundSupport
public let contentListenr = ContentListenr()


public func playgroundPrologue() {
    setProxyDelegate(contentListenr)
    PlaygroundPage.current.needsIndefiniteExecution = true
}

