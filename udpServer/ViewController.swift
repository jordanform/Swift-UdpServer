//
//  ViewController.swift
//  udpServer
//
//  Created by Mick on 2016/9/7.
//  Copyright © 2016年 ChengYang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var isRunning = false
    
    @IBOutlet weak var btnStartStop: UIButton!
    @IBOutlet weak var txtfieldPortNum: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
    private var logMsg: String?
    
    // Prepare UDP socket
    private var udpSocket: GCDAsyncUdpSocket?
    private var tag:Int = 0
    private var packetTransferQueue: dispatch_queue_t?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Use main quese first
        packetTransferQueue = dispatch_queue_create("packetTransferQueue", DISPATCH_QUEUE_SERIAL)
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: packetTransferQueue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStopAction(sender: UIButton) {
        
        
        if isRunning == true {
            
            // Stop udp echo server
            isRunning = false
            
            udpSocket?.close()
            txtfieldPortNum.enabled = true
            btnStartStop.setTitle("Start", forState: .Normal)
        } else {
            
            // Start udp echo server
            if let portNum = txtfieldPortNum.text {
                let port = UInt16(portNum)
                
                if port < 0 || port > 65535 {
                    txtfieldPortNum.text = ""
                }
                
                // try bind to port
                do {
                    try udpSocket!.bindToPort(port!)
                }
                catch let error {
                    print("Error occur \(error)")
                }
                do {
                    try udpSocket!.beginReceiving()
                }
                catch let error {
                    print("Error occur \(error)")
                }
                
                logMsg = "Udp Echo server started on port \(port!)"
                logInfo(logMsg!)
                
                logMsg = ""
                isRunning = true
                txtfieldPortNum.enabled = false
                btnStartStop.setTitle("Stop", forState: .Normal)
            }
        }
    }
    
    func logInfo(msg: String) {
        
        let prefix = "<font color=\"#6A0888\">"
        let suffix = "</font><br/>"
        logMsg = logMsg! + "\(prefix)\(suffix)\(msg)\n"
        let html = "<html><body>\n\(logMsg!)\n</body></html>"
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}

extension ViewController: GCDAsyncUdpSocketDelegate {
    
    @objc func udpSocket(sock: GCDAsyncUdpSocket, didReceiveData data: NSData, fromAddress address: NSData, withFilterContext filterContext: AnyObject?) {
        
        if isRunning == false {
            return
        }
        
        if let msg = String(data: data, encoding: NSUTF8StringEncoding) {
            logInfo(msg)
        }
        else {
            print("Error converting received data!")
        }
        
        udpSocket?.sendData(data, toAddress: address, withTimeout: -1, tag: tag)
    }
}

