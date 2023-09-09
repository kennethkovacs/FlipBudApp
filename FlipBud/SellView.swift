import SwiftUI
import Foundation


enum Condition: String, CaseIterable, Identifiable {
    case none = "Select"
    case new = "New"
    case likeNew = "Like New"
    case veryGood = "Very Good"
    case good = "Good"
    case acceptable = "Acceptable"
    var id: Self { self }
}

struct SellView: View {
    var barcode: String
    var epid: String
    var year: String
    var format: String
    
    @State private var images = [UIImage]()
    @State private var binaryImages: [String] = []
    @State private var isShowingImagePicker = false
    @State private var isShowingSelling = false
    @State private var doneListing = false
    @State private var price = ""
    @State private var name = ""
    // @State private var condition = ""
    @State private var condition = Condition.none
    @State private var extra = ""
    @State private var titleYear = ""
    
    var titleLength: Int {
        return title.count
    }
    
    var title: String {
        if (year != "") {
            titleYear = year
        }
        
        if (extra == "") {
            return "\(name) (\(titleYear)) - \(format) - \(condition.rawValue) Condition"
        } else {
            return "\(name) (\(titleYear)) - \(format) - \(condition.rawValue) Condition - \(extra)"
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("The GodFather", text: $name)
                } header: {
                    Text("Name")
                }
                
                if (year == "") {
                    Section {
                        TextField("1999", text: $titleYear)
                    } header: {
                        Text("Year")
                    }
                }
                
                Section {
                    Picker("Choose condition", selection: $condition) {
                        ForEach(Condition.allCases) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                } header: {
                    Text("Condition")
                }
        
                Section {
                    TextField("Widescreen Collection", text: $extra)
                } header: {
                    Text("Extras")
                }
                
                Section {
                    Text(String(titleLength))
                        .foregroundColor(titleLength > 80 ? .red : .black)
                } header: {
                    Text("Listing Title Length (Max 80)")
                }
                
                Section {
                    TextField("4.99", text: $price)
                } header: {
                    Text("Price")
                }
                
                Button("Take Photo") {
                    isShowingImagePicker = true
                }
                
                Button("Submit") {
                    isShowingSelling = true
                    
                    Task {
                        await sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, images: images, condition: condition.rawValue, name: name)
                        }
                    
                    // sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, images: images, condition: condition.rawValue)
                }
                .disabled(titleLength > 80)
                
//                Button("Submit") {
//                    isShowingSelling = true
//                    if (extra == "") {
//                        let title = "\(name) (\(year)) - \(format) - \(condition.rawValue) Condition"
//                        print("Sending request to list product.")
//                        print("Barcode: \(barcode)")
//                        print("Epid: \(epid)")
//                        print("Title: \(title)")
//                        print("Price: \(price)")
//                        sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, images: images, condition: condition.rawValue)
//                    } else {
//                        let title = "\(name) (\(year)) - \(format) - \(condition.rawValue) Condition - \(extra)"
//                        print("Sending request to list product.")
//                        print("Barcode: \(barcode)")
//                        print("Epid: \(epid)")
//                        print("Title: \(title)")
//                        print("Price: \(price)")
//                        sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, images: images, condition: condition.rawValue)
//                    }
//                    // sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, images: images)
//                }
                
                Button("Go back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(images: $images, isShown: $isShowingImagePicker)
            }
            .sheet(isPresented: $isShowingSelling) {
                if (!doneListing) {
                    Text("Currently listing. Please wait.")
                }
                
                if (doneListing) {
                    Text("Done listing. Please go back.")
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
        }
    }
    
    func convertImageToBase64(image: UIImage) -> String? {
        if let data = image.pngData() {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func sendHTTPRequest(barcode: String, epid: String, title: String, price: String, images: [UIImage], condition: String, name: String) async {
        print("Starting http request...")
        
        guard let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/ebay/listing") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Start building the multipart/form-data body
        var requestBody = Data()
        
        // Barcode, epid, title, and price fields
        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"barcode\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(barcode)\r\n".data(using: .utf8)!)

        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"epid\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(epid)\r\n".data(using: .utf8)!)

        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(title)\r\n".data(using: .utf8)!)

        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"price\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(price)\r\n".data(using: .utf8)!)
        
        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"condition\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(condition)\r\n".data(using: .utf8)!)
        
        requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(name)\r\n".data(using: .utf8)!)
        
        // Resize images
//        var resizedImages = [UIImage]()
//        for image in images {
//            if let resizedImage = resizeImage(image: image, newWidth: 400) {
//                resizedImages.append(resizedImage)
//            } else {
//                print("Failed to resize image.")
//            }
//        }
        
        
        // Add the image data to the raw http request data - JPG
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
                requestBody.append("Content-Disposition: form-data; name=\"image\(index)\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                requestBody.append(imageData)
                requestBody.append("\r\n".data(using: .utf8)!)
            }
        }
        
        // Add the ending boundary
        requestBody.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // setting the body of the post to the reqeustBody with the boundary
        request.httpBody = requestBody
        
        // Handle the response
        do {
            doneListing = true
            let (data, _) = try await URLSession.shared.data(for: request)
            let str = String(data: data, encoding: .utf8)
            print("Server response: \(str ?? "No server response.")")
        } catch {
            print("Error: \(error)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var isShown: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // Leave this empty
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(images: $images, isShown: $isShown)
    }
}

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var images: [UIImage]
    @Binding var isShown: Bool
    
    init(images: Binding<[UIImage]>, isShown: Binding<Bool>) {
        _images = images
        _isShown = isShown
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            images.append(image)
        }
        isShown = false // Dismiss image picker after taking a photo
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}
