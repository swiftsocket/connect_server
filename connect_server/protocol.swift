//
//  protocol.swift
//  connect_server
//
//  Created by 彭运筹 on 15/1/3.
//  Copyright (c) 2015年 pengyunchou. All rights reserved.
//

import Foundation
//消息头标示
public enum MessageControl:Int8{
    case terminal=0x01
    case version=0x02
    case content=0x03
}
//消息头结构
public struct MessageHeader{
    var len:Int32
    var control:MessageControl
    public init(len:Int32,control:MessageControl){
        self.len=len
        self.control=control
    }
}
//消息结构
public struct Message {
    var header:MessageHeader
    public var content:String
    public init(header:MessageHeader,content:String){
        self.header=header
        self.content=content
    }
    public init(control:MessageControl,content:String){
        var len:Int32=4+1+content.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        self.header=MessageHeader(len:len,control:control)
        self.content=content
    }
    public init(msg:String){
        var len:Int32=4+1+msg.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        self.header=MessageHeader(len:len,control:MessageControl.content)
        self.content=msg
    }
}