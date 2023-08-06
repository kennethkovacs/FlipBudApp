//
//  NextView.swift
//  FlipBud
//
//  Created by Kenneth Kovacs on 2023-06-29.
//

import SwiftUI
import CodeScanner

struct NextView: View {
    @State var scannedCode: String
    var responseJSON: [String: Any]
    @State private var isShowingScanner = false
    @State private var isShowingSellScreen = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Estimated prices:")
                    .font(.title)
                
                if let newEst = responseJSON["new_est"] as? Double {
                                Text("New est: \(newEst)")
                                    .font(.headline)
                                    .padding()
                            }
                            
                if let newOtherEst = responseJSON["new_other_est"] as? Double {
                    Text("New other est: \(newOtherEst)")
                        .font(.headline)
                        .padding()
                }
                
                if let preOwnedEst = responseJSON["pre_owned_est"] as? Double {
                    Text("Pre-owned est: \(preOwnedEst)")
                        .font(.headline)
                        .padding()
                }
                
                Button("Sell") {
                    isShowingSellScreen = true
                }
                .sheet(isPresented: $isShowingSellScreen) {
                    let barcode = scannedCode
                    let epid = (responseJSON["epid"] as? String) ?? ""
                    let year = (responseJSON["year"] as? String) ?? ""
                    let format = (responseJSON["format"] as? String) ?? ""
                    
                    SellView(barcode: barcode, epid: epid, year: year, format: format)
                }
                
                Button("Scan again") {
                    isShowingScanner = true
                }
                .sheet(isPresented: $isShowingScanner) {
                    BarcodeScannerView { barcode in
                        isShowingScanner = false
                        scannedCode = barcode
                        print("Detected barcode: \(barcode)")
                        print("Sending HTTP request")
                        // self.sendHTTPRequest(barcode: barcode)
                        print("HTTP request completed")
                    }
                    .edgesIgnoringSafeArea(.all)

                }
                
                Button("Back to Home") {
                               // Dismiss the current view and return to the previous view
                               presentationMode.wrappedValue.dismiss()
                           }
            }
        }
    }
    
    func listProduct() {
        let url = URL(string: "url")!
        var request = URLRequest(url: url)
        
    }
    
    func handleRequest(_ result: String) async {
        print("Starting to handle http request")
        guard let encoded = try? JSONEncoder().encode(result) else {
            print("failed to encode")
            return
        }
        
        let url = URL(string: "https://flipbud.onrender.com/api/dvds/\(result)")!
        var request = URLRequest(url: url)
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type"))
        // request.httpMethod = "GET"
        print("Starting URLSession")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("URLSession successful")
                if let stringResponse = String(data: data, encoding: .utf8) {
                    print(stringResponse)
                }
            } else if let error = error {
                print("HTTP request failed: \(error.localizedDescription)")
            }
        }.resume()
        
        print("Completed http request")
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        print("6")
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            scannedCode = result.string
            print("7")
            // print(result.string)
            
            // Send result to API
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

