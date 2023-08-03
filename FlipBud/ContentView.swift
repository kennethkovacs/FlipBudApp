//
//  ContentView.swift
//  FlipBud
//
//  Created by Kenneth Kovacs on 2023-06-28.
//

import SwiftUI
import CodeScanner


struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var isPresentingScanner = false
    @State private var scannedCode: String?
    @State private var showNext = false
    @State private var responseJSON: [String: Any]?
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Scan code") {
                    isShowingScanner = true
                }
                .padding()
                .sheet(isPresented: $isShowingScanner) {
                    BarcodeScannerView { barcode in
                        isShowingScanner = false
                        scannedCode = barcode
                        print("Detected barcode: \(barcode)")
                        print("Sending HTTP request")
                        self.sendHTTPRequest(barcode: barcode)
                        print("HTTP request completed")
                        // showNext = true
                    }
                    .edgesIgnoringSafeArea(.all)
                    
//                    BarcodeScannerView { barcode in
//                        isShowingScanner = false
//                        scannedCode = barcode
//                        print("Detected barcode: \(barcode)")
//                        print("Sending HTTP request")
//                        self.sendHTTPRequest(barcode: barcode)
//                        print("HTTP request completed")
//                        showNext = true
//                    }
//                    .edgesIgnoringSafeArea(.all)SAn
                }

                if showNext {
                    NavigationLink(destination: NextView(scannedCode: scannedCode ?? ""), isActive: $showNext) {
                        EmptyView()
                    }
                    .navigationTitle("Finish scanning")
                }
            }
            .navigationBarTitle("FlipBud")
        }
        
//        NavigationView {
//            VStack {
//                Button("Scan code") {
//                    isShowingScanner = true
//                }
//            }
//            .padding()
//            .sheet(isPresented: $isShowingScanner) {
//                CodeScannerView(codeTypes: [.ean8, .ean13, .pdf417, .upce], simulatedData: "paul hudson", completion: handleScan)
//            }
//        }
        
        
        
        // Works
//        NavigationView {
//            VStack {
//                Button("Scan code") {
//                    isShowingScanner = true
//                }
//                .padding()
//                .sheet(isPresented: $isShowingScanner) {
//                    CodeScannerView(codeTypes: [.ean13], showViewfinder: true, simulatedData: "kenneth", completion: handleScan)
//                }
//
//                if showNext {
//                    NavigationLink(destination: NextView(scannedCode: scannedCode ?? ""), isActive: $showNext) {
//                        EmptyView()
//                    }
//                    .navigationTitle("Finish scanning")
//                }
//            }
//            .navigationBarTitle("FlipBud")
//        }
    
        
//        NavigationView {
//            VStack {
//                Button("Scan code") {
//                    isShowingScanner = true
//                }
//            }
//            .padding()
//            .sheet(isPresented: $isShowingScanner) {
//                CodeScannerView(codeTypes: [.qr], simulatedData: "paul hudson", completion: handleScan)
//            }
//            .navigationBarTitle("FlipBud")
//            .navigationBarItems(trailing:
//                NavigationLink(destination: NextView(scannedCode: scannedCode ?? ""), isActive: .constant(scannedCode != nil)) {
//                    EmptyView()
//                }
//            )
//        }
        
//        NavigationView {
//            VStack(spacing: 10) {
//                if let code = scannedCode {
//                    NavigationLink("Next page", destination: NextView(scannedCode: code), isActive: .constant(true)).hidden()
//                }
//
//                Button("Scan Code") {
//                    isPresentingScanner = true
//                }
//
//                Text("Scan a QR code to begin")
//            }
//            .sheet(isPresented: $isPresentingScanner) {
//                CodeScannerView(codeTypes: [.qr]) { response in
//                    if case let .success(result) = response {
//                        scannedCode = result.string
//                        isPresentingScanner = false
//                    }
//                }
//            }
//        }
    }
    
    func sendHTTPRequest(barcode: String) {
        // Show sheet after getting response with showNext parameter
        let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/dvds/\(barcode)")!  // Your API endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Server response: \(str ?? "")")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("JSON response: \(json)")
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            // jsonString now contains the JSON data as a string
                            scannedCode = jsonString
                            showNext = true
                        }
                        
//                        if let new = json["new"] as? [String: Any] {
//                            print("Average price of new: \(new["average"])")
//                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
        task.resume()
        
//        print("1")
//        let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/dvds/\(barcode)")!  // Your API endpoint
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data {
//                let str = String(data: data, encoding: .utf8)
//                print("Server response: \(str ?? "")")
//
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print("JSON response: \(json)")
//                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//                        if let jsonString = String(data: jsonData, encoding: .utf8) {
//                            responseJSON = jsonString
//                        }
//                        if let new = json["new"] as? [String: Any] {
//                                print("Average price of new: \(new["average"])")
//                            }
//                    }
//                } catch {
//                    print("Error parsing JSON: \(error)")
//                }
//            }
//        }
//        task.resume()
        }
    

    func handleScan(result: Result<ScanResult, ScanError>) {
         isShowingScanner = false
        
//         NavigationLink("Next page", destination: NextView(scannedCode: "result.string"), isActive: $showNext)
         
         switch result {
         case .success(let result):
             print(result.string)
             scannedCode = result.string
             showNext = true
         case .failure(let error):
             print("Scanning failed: \(error.localizedDescription)")
         }

//        switch result {
//        case .success(let result):
//            print("Line 2")
//            NavigationLink("Next page", destination: NextView(scannedCode: result.string), isActive: .constant(true)).hidden()
//            print("Line 3")
//        case .failure(let error):
//            print("Line 4")
//            print("Scanning failed: \(error.localizedDescription)")
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  FlipBud
//
//  Created by Kenneth Kovacs on 2023-06-28.
//

//import SwiftUI
//import CodeScanner
//
//
//struct ContentView: View {
//    @State private var isShowingScanner = false
//    @State private var isPresentingScanner = false
//    @State private var scannedCode: String?
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 10) {
//                if let code = scannedCode {
//                    NavigationLink("Next page", destination: NextView(scannedCode: code), isActive: .constant(true)).hidden()
//                }
//
//                Button("Scan Code") {
//                    isPresentingScanner = true
//                }
//
//                Text("Scan a QR code to begin")
//            }
//            .sheet(isPresented: $isPresentingScanner) {
//                CodeScannerView(codeTypes: [.ean8, .ean13, .pdf417, .upce], showViewfinder: true) { response in
//                    if case let .success(result) = response {
//                        scannedCode = result.string
//                        isPresentingScanner = false
//                    }
//                }
//            }
//        }
        
//        NavigationView {
//            VStack {
//                // NavigationLink("Mint") { NextView(scannedCode: scannedCode ?? "") }
//
//                Button("Scan code") {
//                    isShowingScanner = true
//                }
//            }
//            .padding()
//        }
//        .sheet(isPresented: $isShowingScanner) {
//            CodeScannerView(codeTypes: [.ean8, .ean13, .pdf417, .upce], showViewfinder: true, completion: handleScan)
//        }
//    }
//
//
//    func handleScan(result: Result<ScanResult, ScanError>) {
//         isShowingScanner = false
//
//         switch result {
//         case .success(let result):
//             scannedCode = result.string
//         case .failure(let error):
//             print("Scanning failed: \(error.localizedDescription)")
//         }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}





