//
//  SellView.swift
//  FlipBud
//
//  Created by Kenneth Kovacs on 2023-08-03.
//

import SwiftUI

struct SellView: View {
    var barcode: String
    var epid: String
    @State private var price = "1234"
    @State private var title = "john doe"
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        Form {
            TextField("Price", text: $price)
            TextField("Title", text: $title)
            Button("Submit") {
                sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price)
            }
            Button("Go back") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func sendHTTPRequest(barcode: String, epid: String, title: String, price: String) {
        let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/ebay/listing")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // The JSON object you want to send.
        let jsonObject: [String: Any] = ["barcode": barcode, "epid": epid, "title": title, "startPrice": price]
        
        // Convert the JSON object to Data.
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
            request.httpBody = jsonData
        }
        
        // Specify the content type of the request.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Handle the response
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Server response: \(str ?? "")")
            }
        }
        task.resume()
    }
}
