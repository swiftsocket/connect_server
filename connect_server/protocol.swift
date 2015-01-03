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

extension TCPClient{
    func readInt32()->Int32?{
        var bytes=self.read(4)
        if let b:[UInt8]=bytes{
            if b.count==4{
                var data:NSData=NSData(bytes: b, length: b.count)
                var value:Int32=0
                data.getBytes(&value, length: 4)
                return value
            }
        }
        return nil
    }
    func readInt8()->Int8?{
        var bytes=self.read(1)
        if let b:[UInt8]=bytes{
            if b.count==1{
                var data:NSData=NSData(bytes: b, length: b.count)
                var value:Int8=0
                data.getBytes(&value, length: 1)
                return value
            }
        }
        return nil
    }
    func readString(len:Int32)->String?{
        var bytes=self.read(Int(len))
        if let b:[UInt8]=bytes{
            if b.count==Int(len){
                return String(bytes: b, encoding: NSUTF8StringEncoding)
            }
        }
        return nil
    }
    func readMessage()->Message?{
        //read message len
        var len:Int32=0
        if var l:Int32=self.readInt32(){
            len=l
        }else{
            return nil
        }
        //read message control
        var msgcontrol:MessageControl
        if var c:Int8=self.readInt8(){
            if let mc:MessageControl=MessageControl(rawValue: c){
                msgcontrol=mc
            }else{
                return nil
            }
        }else{
            return nil
        }
        //read message content
        var content:String
        if let content:String=self.readString(len-5){
            return Message(control: msgcontrol, content: content)
        }else{
            return nil
        }
    }
    func sendMessage(msg:Message){
        var datatosend=NSMutableData()
        var len:Int32=msg.header.len
        var control:Int8=msg.header.control.rawValue
        datatosend.appendBytes(&len, length: 4)
        datatosend.appendBytes(&control, length: 1)
        datatosend.appendData(msg.content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        self.send(data: datatosend)
    }
}


