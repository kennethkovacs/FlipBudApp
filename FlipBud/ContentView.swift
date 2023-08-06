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
    // @State private var scannedCode: String?
    @State private var barcode: String?
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
                        self.barcode = barcode
                        print("Detected barcode: \(barcode)")
                        print("Sending HTTP request")
                        self.sendHTTPRequest(barcode: barcode)
                        print("HTTP request completed")
                    }
                    .edgesIgnoringSafeArea(.all)
                }

                if showNext {
                    NavigationLink(destination: NextView(barcode: barcode ?? "", responseJSON: responseJSON ?? [:]), isActive: $showNext) {
                        EmptyView()
                    }
                    .navigationTitle("Finish scanning")
                }
            }
            .navigationBarTitle("FlipBud")
        }
    }
    
    func sendHTTPRequest(barcode: String) {
        // Show sheet after getting response with showNext parameter
        let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/dvds/\(barcode)")!
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
                            // scannedCode = jsonString
                            responseJSON = json
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
        }
    

    func handleScan(result: Result<ScanResult, ScanError>) {
         isShowingScanner = false
                 
         switch result {
         case .success(let result):
             print(result.string)
             self.barcode = result.string
             showNext = true
         case .failure(let error):
             print("Scanning failed: \(error.localizedDescription)")
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





