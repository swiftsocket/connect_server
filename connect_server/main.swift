//
//  main.swift
//  connect_server
//
//  Created by pengyunchou on 15-1-2.
//  Copyright (c) 2015年 pengyunchou. All rights reserved.
//

import Foundation

var connserver=ConnectServer(identifier:"ixy.io.connector1",addr: "127.0.0.1", port: 8080)
if connserver.run()==true{
    println("server run ok")
}
var stdinhandle=NSFileHandle.fileHandleWithStandardInput()

while true{
    
    
}




