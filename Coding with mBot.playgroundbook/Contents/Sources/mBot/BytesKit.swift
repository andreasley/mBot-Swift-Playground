//
//  BytesKit.swift
//  mZero-iOS
//
//  Created by 彭康政 on 2017/4/11.
//  Copyright © 2017年 Shenzhen Maker Works Technology Co., Ltd. All rights reserved.
//

import Foundation

public protocol BytesConvertible {
    var bytes: [UInt8] { get }
}

extension Data: BytesConvertible {
    public var bytes: [UInt8] {
        var _bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &_bytes, count: count)
        return _bytes
    }
}

extension String: BytesConvertible {
    public var bytes: [UInt8] {
        return utf8.map { $0 }
    }
}

extension CharacterSet {
    public static var hexStringAllowed: CharacterSet {
        return CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
    }
}

extension String {
    public var isValidHexString: Bool {
        guard !self.isEmpty else {
            return false
        }
        let charset = CharacterSet.hexStringAllowed

        for scalar in self.unicodeScalars {

            guard charset.contains(scalar) else {
                return false
            }

        }
        return true
    }
}

extension BytesConvertible {
    public var hexString: String {
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}

extension Array {
    public static func bytes(fromHexString hexString: String) -> [UInt8]? {
        guard hexString.isValidHexString else {
            return nil
        }
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else {
            return nil
        }
        var array = [UInt8]()
        var hasFailure = false
        regex.enumerateMatches(in: hexString, options: [], range: NSMakeRange(0, hexString.characters.count)) {
            match, _, _ in

            guard let match = match else {
                hasFailure = true
                return
            }

            let rangeStart = hexString.index(hexString.startIndex, offsetBy: match.range.location)
            let rangeEnd = hexString.index(rangeStart, offsetBy: match.range.length)

            let byteString = hexString.substring(with: rangeStart ..< rangeEnd)

            guard let num = UInt8(byteString, radix: 16) else {
                hasFailure = true
                return
            }

            array.append(num)

        }

        if hasFailure || array.count <= 0 {
            return nil
        }
        return array
    }
}

extension Data {
    public init?(hexString: String) {
        guard let bytes = [UInt8].bytes(fromHexString: hexString) else {
            return nil
        }
        self = Data(bytes: bytes)
    }
}
