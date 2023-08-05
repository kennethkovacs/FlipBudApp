import SwiftUI

struct SellView: View {
    var barcode: String
    var epid: String
    @State private var images = [UIImage]()
    @State private var binaryImages: [String] = []
    @State private var isShowingImagePicker = false
    @State private var price = "12.34"
    @State private var title = "The Graduate DVD - TEST LISTING"
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Form {
                TextField("Price", text: $price)
                TextField("Title", text: $title)
                Button("Take Photo") {
                    isShowingImagePicker = true
                }
                Button("Done") {
                    // Handle done action here, e.g. API call to send photos to the server
                    print("Sending photos to server")
                    isShowingImagePicker = false
                }
                
                Button("Submit") {
                    print(images.count)
                    sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, images: images)
                }
                
//                Button("Submit") {
//                    print(images.count)
//                    // Convert images to base64 binary
//                    for image in images {
//                        if let base64Image = convertImageToBase64(image: image) {
//                            binaryImages.append(base64Image)
//                        }
//                    }
//
//                    sendHTTPRequest(barcode: barcode, epid: epid, title: title, price: price, binaryImages: binaryImages)
//                }
                Button("Go back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(images: $images, isShown: $isShowingImagePicker)
            }
        }
    }
    
    func convertImageToBase64(image: UIImage) -> String? {
        if let data = image.pngData() {
            return data.base64EncodedString()
        }
        return nil
    }
    
//    func convertImageToBase64(image: UIImage) -> String? {
//        if let data = image.jpegData(compressionQuality: 0.5) {
//            return data.base64EncodedString()
//        }
//        return nil
//    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func sendHTTPRequest(barcode: String, epid: String, title: String, price: String, images: [UIImage]) {
        print("Starting http request...")
        guard let url = URL(string: "https://king-prawn-app-sh6ua.ondigitalocean.app/api/ebay/listing") else {
            print("Invalid URL")
            return
        }
//        guard let url = URL(string: "http://192.168.0.103:8888/api/ebay/listing") else {
//            print("Invalid URL")
//            return
//        }

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
        
        // Resize images
//        var resizedImages = [UIImage]()
//        for image in images {
//            if let resizedImage = resizeImage(image: image, newWidth: 400) {
//                resizedImages.append(resizedImage)
//            } else {
//                print("Failed to resize image.")
//            }
//        }
        
//        // Add the image data to the raw http request data - PNG
//        for (index, image) in resizedImages.enumerated() {
//            if let imageData = image.pngData() {
//                print("Image \(index) successfully converted to PNG.")
//                requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
//                requestBody.append("Content-Disposition: form-data; name=\"image\(index)\"; filename=\"image\(index).png\"\r\n".data(using: .utf8)!)
//                requestBody.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
//                requestBody.append(imageData)
//                requestBody.append("\r\n".data(using: .utf8)!)
//            } else {
//                print("Failed to convert image \(index) to PNG.")
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

    
//    func sendHTTPRequest(barcode: String, epid: String, title: String, price: String, images: [UIImage]) {
//        print("Starting http request...")
//        guard let url = URL(string: "http://192.168.0.103:8888/api/ebay/listing") else {
//            print("Invalid URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        // generate boundary string using a unique per-app string
//        let boundary = UUID().uuidString
//
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//
//        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
//        // And the boundary is also set here
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        // Start building the multipart/form-data body
//        var requestBody = Data()
//
//        // Add the image data to the raw http request data
//        for (index, image) in images.enumerated() {
//            if let imageData = image.jpegData(compressionQuality: 1.0) {
//                requestBody.append("--\(boundary)\r\n".data(using: .utf8)!)
//                requestBody.append("Content-Disposition: form-data; name=\"image\(index)\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
//                requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//                requestBody.append(imageData)
//                requestBody.append("\r\n".data(using: .utf8)!)
//            }
//        }
//
//        // Add other fields if needed (you may need to adjust based on your server/API requirements)
//        requestBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
//
//        // setting the body of the post to the reqeustBody with the boundary
//        request.httpBody = requestBody
//
//        // Handle the response
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data {
//                let str = String(data: data, encoding: .utf8)
//                print("Server response: \(str ?? "")")
//            }
//        }
//        task.resume()
//    }
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
