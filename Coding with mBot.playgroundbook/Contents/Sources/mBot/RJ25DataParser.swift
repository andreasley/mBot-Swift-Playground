//
//  RJ25DataParser.swift
//  mZero-iOS
//
//  Created by CatchZeng on 2017/4/20.
//  Copyright © 2017年 Shenzhen Maker Works Technology Co., Ltd. All rights reserved.
//

import Foundation

@objc public protocol DataParserDelegate {
    func onParseData(_ data: Data)
    func onParseErrorData(_ data: Data)
    func onBufferOverflow(length: Int)
}

public class RJ25DataParser: NSObject {
    public weak var delegate: DataParserDelegate?
    
    private let prefix: UInt8 = 0xff
    private let prefix2: UInt8 = 0x55
    private let suffix: UInt8 = 0x0d
    private let suffix2: UInt8 = 0x0a
    
    var recvLength: Int = 0
    var beginRecv: Bool = false
    var recvView: [UInt8] = Array(repeating: 0x00, count: 1024)
    
    public func addReceived(data: Data) {
        let bytes = data.bytes
        
        for i in 0..<data.count {
            if bytes[i] == prefix {
                if i+1 < data.count {
                    if bytes[i+1] == prefix2 {
                        recvLength = 0
                        beginRecv = true
                    } else {
                        parseMiddle(byte: bytes[i])
                    }
                } else {
                    parseMiddle(byte: bytes[i])
                }
                
            } else if bytes[i] == suffix2 {
                if i-1 >= 0 {
                    if bytes[i-1] == suffix && recvView[1] == prefix2 {
                        combinateData(byte: bytes[i])
                        
                    } else {
                        parseMiddle(byte: bytes[i])
                    }
                } else {
                    parseMiddle(byte: bytes[i])
                }
                
            } else {
                parseMiddle(byte: bytes[i])
            }
        }
    }
    
    private func parseMiddle(byte: UInt8) {
        if beginRecv {
            if recvLength > 1024 {
                delegate?.onBufferOverflow(length: recvLength)
                
                //If overflow then ignore the data before
                recvLength = 0
            }
            
            if byte == suffix2 && recvView[recvLength] == suffix && recvView[1] == prefix2 {
                combinateData(byte: byte)
                
            } else {
                recvLength += 1
                recvView[recvLength] = byte
            }
        }
    }
    
    private func combinateData(byte: UInt8) {
        beginRecv = false
        
        //add suffix2
        recvLength += 1
        recvView[recvLength] = byte
        //add prefix
        recvView[0] = prefix
        
        let parseData = Data(bytes: Array(recvView[0...recvLength]))
        delegate?.onParseData(parseData)
        
        //reset recView
        recvView = Array(repeating: 0x00, count: 1024)
    }
}
