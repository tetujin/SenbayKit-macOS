//
//  ViewController.swift
//  SenbayKit-macOS
//
//  Created by tetujin on 01/13/2019.
//  Copyright (c) 2019 tetujin. All rights reserved.
//

import Cocoa
import SenbayKit_macOS

class ViewController: NSViewController, SenbayReaderDelegate {

    let reader = SenbayReader()
    let config = SenbayReaderConfig()
    
    var captureAreaWindow:NSWindow? = nil
    var captureAreaWindowController:NSWindowController? = nil

    @IBOutlet weak var statusTextArea: NSTextField!
    @IBOutlet weak var dataTextArea: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reader.delegate = self
        
        reader.config.skipDuplicateData = false
        
        let captureArea = CGRect.init(x: config.captureAreaX,
                                      y: config.captureAreaY,
                                      width: config.captureAreaWidth,
                                      height: config.captureAreaHeight)
        captureAreaWindow = NSWindow.init(contentRect: captureArea,
                                          styleMask: .resizable,
                                          backing: .buffered,
                                          defer: false)
        captureAreaWindow?.backgroundColor = NSColor.clear
        captureAreaWindow?.isOpaque = false
        captureAreaWindow?.ignoresMouseEvents = false
        captureAreaWindow?.isMovableByWindowBackground = true
        captureAreaWindow?.contentView?.wantsLayer = true

        NotificationCenter.default.addObserver(self,
                                               selector:#selector(captureAreaDidResize(sender:)),
                                               name: NSWindow.didEndLiveResizeNotification,
                                               object: captureAreaWindow)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(captureAreaDidMove(sender:)),
                                               name: NSWindow.didMoveNotification,
                                               object: captureAreaWindow)
//        [window.contentView addSubview:frameView];
        captureAreaWindowController = NSWindowController.init(window: captureAreaWindow)
        captureAreaWindowController?.showWindow(self)
        
        self.statusTextArea.stringValue = "init SenbayReader"
    }
  
    @objc func captureAreaDidResize(sender:Any){
        self.statusTextArea.stringValue = "called captureAreaDidResize:"
        if let rect = captureAreaWindow?.frame{
            reader.setCaptureAreaWith(rect)
        }
    }
    
    @objc func captureAreaDidMove(sender:Any){
        self.statusTextArea.stringValue = "called captureAreaDidMove:"
        if let rect = captureAreaWindow?.frame{
            reader.setCaptureAreaWith(rect)
        }
    }
    
    @IBAction func pushedReaderControlButton(_ sender: NSButton) {
        if(sender.title == "Start"){
            captureAreaWindow?.contentView?.layer?.borderWidth = 5;
            captureAreaWindow?.contentView?.layer?.borderColor = NSColor.yellow.cgColor
            sender.title = "Stop"
            reader.adjustCaptureArea()
            reader.start()
            self.statusTextArea.stringValue = "start SenbayReader"
            
        }else{
            captureAreaWindow?.contentView?.layer?.borderWidth = 0;
            captureAreaWindow?.contentView?.layer?.borderColor = NSColor.clear.cgColor
            sender.title = "Start"
            reader.stop()
            self.statusTextArea.stringValue = "stop SenbayReader"
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func didDetectQRcode(_ qrcode: String) {
        
    }

    func didDecodeQRcode(_ data: [String : NSObject]) {
        self.statusTextArea.stringValue = "didDecodeQRcode:"
        self.dataTextArea.stringValue = data.debugDescription
        
    }
    
    func didChangeCaptureArea(_ rect: CGRect) {
        print(rect)
        self.statusTextArea.stringValue = "change the capture area"
        captureAreaWindow?.setFrame(rect, display: true)
    }
    
}

