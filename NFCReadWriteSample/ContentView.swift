//
//  ContentView.swift
//  NFCReadWriteSample
//
//  Created by Maochun on 2023/12/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        @State var showAlert = false
        @State var textToWrite = ""
        
        var readText = ""
        let nfcHandler = NFCOperationsHandler()
        VStack {
            Button(action: {
                readText = nfcHandler.readFromNFC() ?? "Failed to read from NFC tag!"
                showAlert = true
                print("Read done \(readText)")
            }) {
                Text("Read NFC")
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 60, alignment: .center)
            .background(Color.blue)
            .cornerRadius(30)
            .padding()
            .alert(textToWrite, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            
            TextField("Enter NFC tag text", text: $textToWrite)
                .frame(width: UIScreen.main.bounds.width - 32, height: 300, alignment: .center)
                .multilineTextAlignment(.leading)
                .overlay {
                    textFieldBorder
                }
            
            
            Button(action: {
                let ret = nfcHandler.writeToNFC(url: "www.google.com", text: textToWrite)
                print("write done! \(ret)")
            }) {
                Text("Write NFC")
                    .foregroundColor(.white)
                    .padding()
            }
//            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .frame(width: UIScreen.main.bounds.width - 32, height: 60, alignment: .center)
        
            .background(Color.green)
            .cornerRadius(30)
            
//            .border(.pink)
            
        }
        .padding()
        
    }
    
    var textFieldBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.green, lineWidth: 2)
    }
}

#Preview {
    ContentView()
}
