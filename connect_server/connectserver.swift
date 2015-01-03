//
//  connectserver.swift
//  connect_server
//
//  Created by pengyunchou on 15-1-3.
//  Copyright (c) 2015年 pengyunchou. All rights reserved.
//

import Foundation
//消息头标示
enum MessageControl:Int8{
    case terminal=0x01
    case version=0x02
    case content=0x03
}
//消息头结构
struct MessageHeader{
    var len:Int32
    var control:MessageControl
    init(len:Int32,control:MessageControl){
        self.len=len
        self.control=control
    }
}
//消息结构
struct Message {
    var header:MessageHeader
    var content:String
    init(header:MessageHeader,content:String){
        self.header=header
        self.content=content
    }
    init(control:MessageControl,content:String){
        var len:Int32=4+1+content.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        self.header=MessageHeader(len:len,control:control)
        self.content=content
    }
}
class ClientConn{
    private var server:ConnectServer!
    private var tcpclient:TCPClient!
    private var alive:Bool=true
    init(client:TCPClient,server:ConnectServer){
        self.tcpclient=client
        self.server=server
    }
    //客户端连接消息循环
    func messageloop(){
        while self.alive==true{
            var data = self.tcpclient.read(1024)
            if let d:[UInt8]=data{
                if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                    println("read from"+self.tcpclient.addr+" message:"+str)
                }
            }else{
                self.alive=false
            }
        }
        self.server.killClient(self)
    }
}

public class ConnectServer {
    //tcp 链接
    private var tcpserver:TCPServer!
    //接受客户端连接的队列
    private var serverqueue=dispatch_queue_create("queue.server", DISPATCH_QUEUE_CONCURRENT)
    //客户端消息处理队列
    private var clientqueue=dispatch_queue_create("queue.client", DISPATCH_QUEUE_CONCURRENT)
    //服务器是否在运行
    var running:Bool!
    //客户端列表
    var clients:NSMutableArray=NSMutableArray()
    //客户端列表锁
    var clientsLock=NSLock()
    init(addr:String,port:Int){
        self.tcpserver=TCPServer(addr: addr, port: port)
    }
    //客户端接入
    private func joinClient(client:ClientConn){
        self.clientsLock.lock()
        println("new client from "+client.tcpclient!.addr)
        self.clients.addObject(client)
        self.clientsLock.unlock()
        dispatch_async(self.clientqueue, { () -> Void in
            client.messageloop()
        })
    }
    //客户端退出
    private func killClient(client:ClientConn){
        self.clientsLock.lock()
        println("client leave from "+client.tcpclient!.addr)
        (self.clients as NSMutableArray).removeObject(client)
        self.clientsLock.unlock()
    }
    public func run(){
        var (success,msg)=self.tcpserver.listen()
        if success==true{
            self.running=true
            dispatch_async(self.serverqueue, { () -> Void in
                self.runloop()
            })
        }else{
            print(msg)
        }
    }
    //循环接收客户连接
    private func runloop(){
        while self.running==true{
            var c=self.tcpserver.accept()
            if let client=c{
                //加入客户连接
                self.joinClient(ClientConn(client: client, server:self))
            }else{
                print("accept error")
            }
        }
    }
}
