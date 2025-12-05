//
//  ImagePicker.swift
//  PhotoEditor
//
//  A simple UIKit-based image picker wrapped for SwiftUI with iOS 13+ support
//  Developed by Noman Belim
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var image: UIImage?
    var onImagePicked: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                parent.onImagePicked(nil)
                parent.dismiss()
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
                    self.parent.dismiss()
                }
            }
        }
    }
}



