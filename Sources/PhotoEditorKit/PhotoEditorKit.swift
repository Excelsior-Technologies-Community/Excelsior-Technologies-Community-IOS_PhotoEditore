//
//  PhotoEditorKit.swift
//  PhotoEditorKit
//
//  A powerful photo editing package for iOS
//

import SwiftUI

/// Main public interface for PhotoEditorKit
/// 
/// Usage:
/// ```swift
/// import PhotoEditorKit
/// 
/// struct MyView: View {
///     var body: some View {
///         PhotoEditorView()
///     }
/// }
/// ```
public struct PhotoEditorKit {
    /// Current version of the package
    public static let version = "1.0.0"
    
    /// Minimum supported iOS version
    public static let minimumIOSVersion = "15.0"
    
    /// Check if advanced background removal is available (iOS 17+)
    public static var isAdvancedBackgroundRemovalAvailable: Bool {
        if #available(iOS 17.0, *) {
            return true
        }
        return false
    }
    
    /// Check if person segmentation is available (iOS 15+)
    public static var isPersonSegmentationAvailable: Bool {
        if #available(iOS 15.0, *) {
            return true
        }
        return false
    }
    
    /// Check if basic background removal is available (iOS 14+)
    public static var isBasicBackgroundRemovalAvailable: Bool {
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }
}

// Re-export the main view for easier import
public typealias PhotoEditorView = ContentView

