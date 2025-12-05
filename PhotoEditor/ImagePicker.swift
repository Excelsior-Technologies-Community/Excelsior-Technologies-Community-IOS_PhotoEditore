//
//  ImagePicker.swift
//  PhotoEditor
//
//  A simple UIKit-based image picker wrapped for SwiftUI with iOS 13+ support
//  Developed by Noman Belim
//

import SwiftUI
import PhotosUI

@available(iOS 14.0, *)
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var image: UIImage?
    var onImagePicked: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        if #available(iOS 14, *) {
            // Use PHPickerViewController for iOS 14+
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = context.coordinator
            return picker
        } else {
            // Fallback to UIImagePickerController for iOS 13
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        // For iOS 14+ (PHPickerViewController)
        @available(iOS 14, *)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                parent.onImagePicked(nil)
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { object, error in
                DispatchQueue.main.async {
                    if let uiImage = object as? UIImage {
                        self.parent.image = uiImage
                        self.parent.onImagePicked(uiImage)
                    } else {
                        self.parent.onImagePicked(nil)
                    }
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        // For iOS 13 (UIImagePickerController)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImagePicked(uiImage)
            } else {
                parent.onImagePicked(nil)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}



