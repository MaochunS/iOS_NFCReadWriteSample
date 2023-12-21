//
//  ContentView.swift
//  NFCReadWriteSample
//
//  Created by Maochun on 2023/12/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
   
        let nfcHandler = NFCOperationsHandler()
        VStack {
            Button(action: {
                let str = nfcHandler.readFromNFC()
                print("Read done \(str ?? "failed")")
            }) {
                Text("Read NFC")
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color.blue)
            .cornerRadius(10)
            .frame(width: 300, height: 50)
            
            Button(action: {
                let ret = nfcHandler.writeToNFC(url: "www.google.com", text: "Maochun Test test")
                print("write done! \(ret)")
            }) {
                Text("Write NFC")
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color.green)
            .cornerRadius(10)
            .frame(width: 300, height: 50)
            
        }
        .padding()
        
    }
}

#Preview {
    ContentView()
}
