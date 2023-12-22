//
//  NFCOperationsHandler.swift
//  NFCReadWriteSample
//
//  Created by Maochun on 2023/12/20.
//

import Foundation
import CoreNFC

class NFCOperationsHandler: NSObject{
    
    var nfcSession: NFCNDEFReaderSession?
    var urlToWrite = ""
    var dataToWrite: Data? = nil
    var textRead: String? = nil
    
    let taskDG = DispatchGroup()
    var operationDone = false
    
    func readFromNFC() -> String?{
        guard NFCNDEFReaderSession.readingAvailable else {
            // NFC is not supported on this device
            return nil
        }
        
        self.operationDone = false
        self.textRead = nil
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
        
        taskDG.enter()
        DispatchQueue.global().async {
            while true{
                if self.textRead != nil{
                    break
                }
                
                if self.operationDone{
                    break
                }
                
                usleep(100000)
                
            }
            
            self.taskDG.leave()
            
        }
        taskDG.wait()
        
        return textRead
    }
    
    func writeToNFC(url:String, text:String) -> Bool{
        
        if let d = text.data(using: .utf8){
            return self.writeToNFC(url: url, data:d)
        }
        return false
    }
    
    func writeToNFC(url:String, data:Data) -> Bool{
        self.dataToWrite = data
        self.urlToWrite = url
        
        self.operationDone = false
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
        
        taskDG.enter()
        DispatchQueue.global().async {
            while true{
                if self.dataToWrite == nil{
                    break
                }
                
                if self.operationDone{
                    break
                }
                usleep(100000)
                
            }
            
            self.taskDG.leave()
            
        }
        taskDG.wait()
        
        let ret = self.dataToWrite == nil
        self.dataToWrite = nil
        return ret
    }
}
    
extension NFCOperationsHandler: NFCNDEFReaderSessionDelegate{

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
        self.operationDone = true
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        var nfcString = ""
        for message in messages {
            
            for record in message.records {
                if let string = String(data: record.payload, encoding: .utf8) {
                    print(string)
                    
//                    var type = "Unknown"
                    if let typeStr = String(data: record.type, encoding: .utf8){
                        print("Type: \(typeStr)")
                        
                        if typeStr == "U"{
//                            type = "URI"
                        }else if typeStr == "T"{
//                            type = "Text"
                            self.textRead = string
                        }else if typeStr == "Sp"{
//                            type = "Smart Poster"
                        }
                    }
                    
//                    nfcString += "Type: \(type)  Data: \(string)\n\n"
                    
                }

                print("Type name format: \(record.typeNameFormat)")
                print("Payload: \(record.payload.count)")
                
            }

        }
        
        session.invalidate()
       
    }
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]){
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                    return
                } else if nil != error {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    return
                }
                
                if let dataWrite = self.dataToWrite{
                    switch ndefStatus {
                    case .notSupported:
                        session.alertMessage = "Tag is not NDEF compliant."
                        session.invalidate()
                    case .readOnly:
                        session.alertMessage = "Tag is read only."
                        session.invalidate()
                    case .readWrite:

                        let uriPayloadFromURL = NFCNDEFPayload.wellKnownTypeURIPayload(
                            url: URL(string: self.urlToWrite)!
                        )!
                        
                        let textPayload = NFCNDEFPayload.init(
                                                           format: .nfcWellKnown,
                                                           type: "T".data(using: .utf8)!,
                                                           identifier: Data(),
                                                           payload:dataWrite)
                        
                        let messge = NFCNDEFMessage.init(records: [textPayload, uriPayloadFromURL])
                        
                        tag.writeNDEF(messge, completionHandler: { (error: Error?) in
                            if nil != error {
                                session.alertMessage = "Write NDEF message fail: \(error!)"
                            } else {
                                session.alertMessage = "Write NDEF message successful."
                                self.dataToWrite = nil
                            }
                            session.invalidate()
                        })
                        
                        
                    @unknown default:
                        session.alertMessage = "Unknown NDEF tag status."
                        session.invalidate()
                    }
                }else{
                    tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                        var statusMessage: String
                        if nil != error || nil == message {
                            statusMessage = "Fail to read NDEF from tag"
                        } else {
                            statusMessage = "Found 1 NDEF message"
                            
                            if let message = message{
                                for record in message.records {
                                    if let string = String(data: record.payload, encoding: .utf8) {
                                        print(string)
                                        
//                                        var type = "Unknown"
                                        if let typeStr = String(data: record.type, encoding: .utf8){
                                            print("Type: \(typeStr)")
                                            
                                            if typeStr == "U"{
//                                                type = "URI"
                                            }else if typeStr == "T"{
//                                                type = "Text"
                                                self.textRead = string
                                            }else if typeStr == "Sp"{
//                                                type = "Smart Poster"
                                            }
                                        }
                                        
//                                        self.textRead += "Type: \(type)  Data: \(string)\n\n"
                                        
                                    }
                                    print(self.textRead ?? "")
                                    print("Type name format: \(record.typeNameFormat)")
                                    print("Payload: \(record.payload.count)")
                                    
                                }
                            }
                        }
                        
                        session.alertMessage = statusMessage
                        session.invalidate()
                    })
                }
            })
        })
    }
    
}
