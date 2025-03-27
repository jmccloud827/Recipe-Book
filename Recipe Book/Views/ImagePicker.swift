import PhotosUI
import SwiftUI

struct ImagePicker<Content: View>: View {
    @Binding var data: Data?
    @ViewBuilder let content: (Binding<Bool>) -> Content
    
    @State private var showSheet = false
    @State private var showActionSheet = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        Button {
            showActionSheet = true
        } label: {
            content($showActionSheet)
        }
        .confirmationDialog("How would you like to upload?", isPresented: $showActionSheet) {
            Button("Camera") {
                source = .camera
                showSheet = true
            }
            
            Button("Photo Library") {
                source = .photoLibrary
                showSheet = true
            }
        }
        .fullScreenCover(isPresented: $showSheet) {
            CameraView(sourceType: source) { uiImage in
                withAnimation {
                    self.data = uiImage?.pngData()
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private struct CameraView: UIViewControllerRepresentable {
        @Environment(\.dismiss) var dismiss
        
        var sourceType: UIImagePickerController.SourceType
        var onDidFinish: (UIImage?) -> Void = { _ in }
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = context.coordinator
            return imagePicker
        }
        
        func updateUIViewController(_: UIImagePickerController, context _: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
    }

    private class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                return
            }
            self.parent.onDidFinish(selectedImage)
            self.parent.dismiss()
        }
    }
}

#Preview {
    @Previewable @State var data: Data?
    
    VStack {
        ImagePicker(data: $data) { _ in
            Text("Test")
        }
       
        if let data,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 200, height: 200)
        }
    }
}
