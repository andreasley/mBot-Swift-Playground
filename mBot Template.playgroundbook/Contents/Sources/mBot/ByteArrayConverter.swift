//
//  ByteArrayConverter.swift
//  mZero-iOS
//
//  Created by CatchZeng on 2017/4/16.
//  Copyright © 2017年 Shenzhen Maker Works Technology Co., Ltd. All rights reserved.
//

import Foundation

/// Reference Link: 
/// http://www.itwendao.com/article/detail/220217.html
/// http://stackoverflow.com/questions/26953591/how-to-convert-a-double-into-a-byte-array-in-swift

open class ByteArrayConverter: NSObject {

    static func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }

    static func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }
}
