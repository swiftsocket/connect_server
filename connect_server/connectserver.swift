//
//  connectserver.swift
//  connect_server
//
//  Created by pengyunchou on 15-1-3.
//  Copyright (c) 2015年 pengyunchou. All rights reserved.
//

import Foundation

class ClientConn{
    private var server:ConnectServer!
    private var tcpclient:TCPClient!
    private var alive:Bool=true
    private var version:String?
    init(client:TCPClient,server:ConnectServer){
        self.tcpclient=client
        self.server=server
    }
    
    //收到一条完整的消息
    func postmessage(msg:Message){
        println("["+self.tcpclient.addr+"]recive:"+msg.content)
    }
    //发送消息给客户端
    func sendmessage(msg:Message){
        println("["+self.tcpclient.addr+"]send:"+msg.content)
        self.tcpclient.sendMessage(msg)
    }
    //客户端连接消息循环
    func messageloop(){
        while self.alive==true{
            //read message
            if let msg:Message=self.tcpclient.readMessage(){
                self.postmessage(msg)
            }else{
                self.alive=false
                break
            }
        }
        self.tcpclient.close()
        self.server.killClient(self)
    }
}

public class ConnectServer {
    // server identifier
    public var identifier:String!
    //tcp 链接
    private var tcpserver:TCPServer!
    //接受客户端连接的队列
    private var serverqueue=dispatch_queue_create("queue.server", DISPATCH_QUEUE_CONCURRENT)
    //客户端消息处理队列
    private var clientqueue=dispatch_queue_create("queue.client", DISPATCH_QUEUE_CONCURRENT)
    //消息发送队列
    private var msgqueue=dispatch_queue_create("queue.msg", DISPATCH_QUEUE_SERIAL)
    //服务器是否在运行
    var running:Bool!
    //客户端列表
    var clients:NSMutableArray=NSMutableArray()
    //客户端列表锁
    var clientsLock=NSLock()
    init(identifier:String,addr:String,port:Int){
        self.tcpserver=TCPServer(addr: addr, port: port)
        self.identifier=identifier
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
    public func stop(){
        self.running=false
        self.tcpserver.close()
    }
    public func run()->Bool{
        var (success,msg)=self.tcpserver.listen()
        if success==true{
            self.running=true
            dispatch_async(self.serverqueue, { () -> Void in
                self.runloop()
            })
            return true
        }else{
            print(msg)
        }
        return false
    }
    public func boardcast(m:Message){
        self.clientsLock.lock()
        for client in self.clients{
            dispatch_async(self.msgqueue, { () -> Void in
                var c=client as ClientConn
                c.sendmessage(m)
            })
        }
        self.clientsLock.unlock()
    }
    //循环接收客户连接
    private func runloop(){
        while self.running==true{
            var c=self.tcpserver.accept()
            if let client=c{
                //加入客户连接
                self.joinClient(ClientConn(client: client, server:self))
            }else{
                print("accept error\n")
            }
        }
    }
}
