//
//  BluetoothConstant.swift
//  MBBlueToothCenter
//
//  Created by block Make on 2017/7/4.
//  Copyright © 2017年 block Make. All rights reserved.
//

import CoreBluetooth
import Foundation

extension CBUUID {
    //mBot services
    @nonobjc static let transDataService = CBUUID(string:"FFF0")
    @nonobjc static let transDataDualService = CBUUID(string:"FFE1")
    
    //Service characteristics
    @nonobjc static let transDataCharateristic = CBUUID(string:"FFF1")
    @nonobjc static let transDataDualCharateristic = CBUUID(string:"FFE3")
    @nonobjc static let notifyDataCharateristic = CBUUID(string:"FFF4")
    @nonobjc static let notifyDataDualCharateristic = CBUUID(string:"FFE2")
}

struct Makeblock {
    static let devicePrefix = "Makeblock"
}
