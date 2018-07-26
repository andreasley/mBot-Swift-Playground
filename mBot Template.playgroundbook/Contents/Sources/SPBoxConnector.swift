//
//  SPConnector.swift
//  PlaygroundContent
//
//  Created by Jordan Hesse on 2017-04-25.
//  Copyright © 2017 Sphero Inc. All rights reserved.
//

import UIKit
import CoreBluetooth
import PlaygroundBluetooth

public struct SPConnectorItem {
    private(set) var prefix: String
    private(set) var defaultName: String
    private(set) var icon: UIImage
}

private let defaultSignalThreshold = 92

class SPConnector: PlaygroundBluetoothConnectionViewDelegate, PlaygroundBluetoothConnectionViewDataSource {
    
    private let items: [SPConnectorItem]
    private let signalThreshold: Int
    
    private let issueIcon = UIImage.init(named: "light") ?? UIImage()

    init(items: [SPConnectorItem], signalThreshold: Int = defaultSignalThreshold) {
        self.items = items
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.signalThreshold = signalThreshold - 6
        } else {
            self.signalThreshold = signalThreshold
        }
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldDisplayDiscovered peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
        guard rssi < 0.0 && rssi > -60.0 else { return false }
        guard let name = peripheral.name, name.hasPrefix("Makeblock") else { return false }
        return true
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldConnectTo peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
        return true
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, willDisconnectFrom peripheral: CBPeripheral) {
        
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
        switch state {
        case .noConnection:
            return NSLocalizedString("connection.view.noConnection", value: "Connect Robot", comment: "Connection view state -- not connected")
        case .connecting:
            return NSLocalizedString("connection.view.connecting", value: "Connecting Robot", comment: "Connection view state -- connecting")
        case .searchingForPeripherals:
            return NSLocalizedString("connection.view.searching", value: "Searching for Robots", comment: "Connection view state -- searching for robots")
        case .selectingPeripherals:
            return NSLocalizedString("connection.view.selecting", value: "Select a Robot", comment: "Connection view state -- selecting a robot")
        case .connectedPeripheralFirmwareOutOfDate:
            return NSLocalizedString("connection.view.firmwareoutofdate", value: "Connect to a Different Robot", comment: "Connection view state -- Robot cannot be used")
        }
        switch state {
        case .noConnection:
            return "未连接"
        case .connecting:
            return "正在连接"
        case .searchingForPeripherals:
            return "正在搜索"
        case .selectingPeripherals:
            return "选择设备"
        case .connectedPeripheralFirmwareOutOfDate:
            return "连接超时"
        }
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
        return "请购买"
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, itemForPeripheral peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) -> PlaygroundBluetoothConnectionView.Item {
//        MBotService.moveForward(speed: 100, duration: 1)
        let name = peripheral.name ?? "none"
        return PlaygroundBluetoothConnectionView.Item(name: name, icon: issueIcon, issueIcon: issueIcon, firmwareStatus: .upToDate)
    }
    
}

public class ConnectionHintArrowView: UIView {
    private var arrowImageView: UIImageView?
    private let arrowImage = UIImage()
    
    public func show() {
        if arrowImageView != nil { return }
        
        let imageView = UIImageView()
        imageView.image = arrowImage
        
        arrowImageView = imageView
        
        imageView.frame.size = arrowImage.size
        imageView.frame.origin.x = -arrowImage.size.width
        imageView.frame.origin.y = 14.0
        
        addSubview(imageView)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationRepeatAutoreverses(true)
        UIView.setAnimationRepeatCount(.infinity)
        
        imageView.frame.origin.x -= 20
        
        UIView.commitAnimations()
    }
    
    public func hide() {
        arrowImageView?.removeFromSuperview()
        arrowImageView = nil
    }
}

