//
//  main.swift
//  connect_server
//
//  Created by pengyunchou on 15-1-2.
//  Copyright (c) 2015年 pengyunchou. All rights reserved.
//

import Foundation

var connserver=ConnectServer(addr: "127.0.0.1", port: 8080)
connserver.run()

while connserver.running!==true{
    NSRunLoop.currentRunLoop().runUntilDate(NSDate.distantFuture() as NSDate)
}




