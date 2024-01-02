//
//  ContentView.swift
//  NFCReadWriteSample
//
//  Created by Maochun on 2023/12/20.
//

import SwiftUI

struct ContentView: View {
    @State var showAlert = false
    @State var textToWrite = ""
    @FocusState var inputIsFocused:Bool
    
    @State var readText = ""
    @State var nfcHandler = NFCOperationsHandler()
    
    var body: some View {
        
        VStack {
            Button(action: {
                readText = nfcHandler.readFromNFC() ?? "Failed to read from NFC tag!"

                print("Read done \(readText)")
                showAlert = true
                
            }) {
                Text("Read NFC")
                    .foregroundColor(.white)
                    .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Read from NFC tag:"),
                    message: Text(readText)
                )
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(30)
            .padding(.bottom, 40)
            
            
            TextField("Enter NFC tag text", text: $textToWrite)
                .frame(height:300)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
                .overlay {
                    textFieldBorder
                }
                .focused($inputIsFocused)
            
            Button(action: {
                inputIsFocused = false
                let ret = nfcHandler.writeToNFC(url: "www.google.com", text: textToWrite)
                print("write done! \(ret)")
            }) {
                Text("Write NFC")
                    .foregroundColor(.white)
                    .padding()
            }
//            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .frame(minWidth: 0, maxWidth: .infinity)
        
            .background(Color.green)
            .cornerRadius(30)
            
//            .border(.pink)
            
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    inputIsFocused = false
                }
            }
        }
    }
    
    var textFieldBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.green, lineWidth: 2)
    }
}

#Preview {
    ContentView()
}
