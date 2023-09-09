//
//  NextView.swift
//  FlipBud
//
//  Created by Kenneth Kovacs on 2023-06-29.
//

import SwiftUI
import CodeScanner

struct NextView: View {
    // @State var scannedCode: String
    @State var barcode: String
    var responseJSON: [String: Any]
    @State private var isShowingScanner = false
    @State private var isShowingSellScreen = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var estimatedPrice: Double? = nil
    
    var body: some View {
        NavigationView {
            VStack {
//                Text("Estimated prices:")
//                    .font(.title)
                
//                Text("Estimated prices:")
//                                    .font(.title)
//                                    .onAppear {
//                                        if let stringValue = responseJSON["new_est"] as? String,
//                                           let doubleValue = Double(stringValue) {
//                                            self.estimatedPrice = doubleValue
//                                        } else {
//                                            self.estimatedPrice = nil
//                                        }
//                                    }
//
//                                // Reference the state variable here
//                                if let price = estimatedPrice {
//                                    Text("Estimated price: \(price)")
//                                        .font(.title)
//                                } else {
//                                    Text("Error retrieving price.")
//                                        .font(.title)
//                                }
                // Print value type
//                Text("Estimated prices:")
//                    .font(.title)
//                    .onAppear { // Add the onAppear modifier here
//                        if let value = responseJSON["new_est"] {
//                                print("Type of new_est: \(type(of: value))")
//                            } else {
//                                print("new_est not found")
//                            }
//                         print("responseJSON new_est: \(responseJSON["new_est"])")
//                         print("responseJSON contents: \(responseJSON)")
//                    }
                
//                Text("Estimated price: \(responseJSON["new_est"] as? Double ?? 0.0)")
//                    .font(.title)
                                
                if let newEst = responseJSON["new_est"] as? String {
                                Text("New est: \(newEst)")
                                    .font(.headline)
                                    .padding()
                            }
                            
                if let newOtherEst = responseJSON["new_other_est"] as? String {
                    Text("New other est: \(newOtherEst)")
                        .font(.headline)
                        .padding()
                }
                                
                if let preOwnedEst = responseJSON["pre_owned_est"] as? String {
                    Text("Pre-owned est: \(preOwnedEst)")
                        .font(.headline)
                        .padding()
                }
                
                Button("Sell") {
                    isShowingSellScreen = true
                }
                .sheet(isPresented: $isShowingSellScreen) {
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
                        self.barcode = barcode
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
    
//    func sendHTTPRequest(barcode: String) {
//        // Show sheet after getting response with showNext parameter
//        let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/dvds/\(barcode)")!
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
//                            responseJSON = json
//                            showNext = true
//                        }
//                    }
//                } catch {
//                    print("Error parsing JSON: \(error)")
//                }
//            }
//        }
//        task.resume()
//    }
    
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
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            self.barcode = result.string
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

