//
//  MBotDataInterpreter.swift
//  mZero-iOS
//
//  Created by CatchZeng on 2017/4/24.
//  Copyright © 2017年 Shenzhen Maker Works Technology Co., Ltd. All rights reserved.
//

import Foundation

class RJ25DataInterpreter: NSObject {
    
    public func interpreter(data: Data, callback: ((_ index: Int, _ value: Float) -> Void)) {
        if data.bytes.count < 10 {
            callback(-1, 0)
            return
        }
        
        // get index
        let index = Int(data.bytes[2])
        
        // get value
        if data.bytes[3] == 0x02 { //Float
            let bytes = [data.bytes[4], data.bytes[5], data.bytes[6], data.bytes[7]]
            let value: Float = ByteArrayConverter.fromByteArray(bytes, Float.self)
            callback(index, value)
        }
    }
}
