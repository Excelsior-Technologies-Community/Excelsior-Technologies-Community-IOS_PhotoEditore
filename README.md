# 📸 PhotoEditorKit

> **By Excelsior Technologies Community** | Developed by Noman Belim

A powerful, feature-rich photo editing Swift Package for iOS apps with AI-powered background removal, filters, blur effects, text overlays, and intelligent cropping.

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

### 🎨 Core Editing Tools
- ✅ **Text Overlays** - Add customizable text with drag, pinch-to-resize, and color selection
- ✅ **Smart Crop** - Interactive crop with pinch-to-zoom and pan (Free, Square, 4:3, 16:9, 3:2)
- ✅ **10+ Filters** - Sepia, Noir, Chrome, Fade, Instant, Mono, Vivid, and more
- ✅ **Blur Effects** - Gaussian, Motion, and Zoom blur with selective focus area
- ✅ **AI Background Removal** - Multi-iOS version support (iOS 13+, 15+, 17+)
- ✅ **Undo/Redo** - Full edit history with up to 10 states
- ✅ **High-Resolution Export** - Smart scaling for optimal quality and performance

### 🤖 AI Features
- **iOS 17+**: Advanced subject extraction (people, animals, objects) - 95-99% accuracy
- **iOS 15-16**: Person segmentation for portraits - 85-90% accuracy
- **iOS 13-14**: Saliency-based detection - 70-80% accuracy

### 🎯 Advanced Capabilities
- **Selective Blur** - Focus area with adjustable circular mask
- **Interactive Crop** - Zoom up to 10x for precise detail cropping
- **Real-time Preview** - See changes instantly
- **Memory Efficient** - Auto-scales images to prevent crashes
- **Orientation Preservation** - No rotation issues

## 📋 Requirements

- **iOS 15.0+** (for modern SwiftUI and Person Segmentation)
- Xcode 14.0+
- Swift 5.9+

## 📦 Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore
   ```
3. Select branch: **Stages**
4. Click **Add Package**

### Manual Installation

1. Download the source code
2. Copy `Sources/PhotoEditorKit` to your project
3. Add the files to your target

## 🚀 Quick Start

### Basic Usage

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    var body: some View {
        PhotoEditorView()
    }
}
```

### With Custom Configuration

```swift
import SwiftUI
import PhotoEditorKit

struct MyApp: View {
    @State private var showEditor = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            Button("Open Photo Editor") {
                showEditor = true
            }
        }
        .sheet(isPresented: $showEditor) {
            PhotoEditorView()
        }
    }
}
```

### Pre-loading an Image

```swift
struct PhotoEditingView: View {
    let imageToEdit: UIImage
    
    var body: some View {
        PhotoEditorView(inputImage: imageToEdit)
    }
}
```

## 📖 Detailed Usage Guide

### 1. Text Overlay

```swift
// Users can:
// 1. Tap "Text" button
// 2. Enter text and choose color
// 3. Tap "Add"
// 4. Drag to reposition
// 5. Pinch to resize
// 6. Double-tap to delete
```

### 2. Crop Tool

```swift
// Interactive crop with zoom & pan:
// 1. Tap "Crop"
// 2. Choose aspect ratio (Free, Square, 4:3, 16:9, 3:2)
// 3. Pinch to zoom (0.3x - 10x)
// 4. Drag to reposition
// 5. Tap "Apply Crop"
```

**Example**: Crop just one person from a group photo
- Select "Free" aspect ratio
- Pinch to zoom in close on the person
- Drag to center them
- Apply crop

### 3. Filters

```swift
// Available filters:
// - Sepia
// - Noir (Black & White)
// - Chrome
// - Fade
// - Instant
// - Mono
// - Process
// - Tonal
// - Transfer
// - Vivid

// Each filter has adjustable intensity slider
```

### 4. Blur Effects

```swift
// Three blur styles:
// 1. Gaussian - Uniform blur
// 2. Motion - Directional blur
// 3. Zoom - Radial blur from center

// Selective Blur (Focus Area):
// 1. Enable "Focus Area" toggle
// 2. Drag circle to position sharp area
// 3. Pinch to resize focus area
// 4. Tap "Apply Selective Blur"
```

### 5. Remove Background

```swift
// AI-powered background removal:
// 1. Tap "Remove BG"
// 2. Tap "Remove Background" button
// 3. Wait 1-3 seconds for AI processing
// 4. Background automatically removed!

// Supports iOS 13+ with automatic fallback:
// - iOS 17+: Advanced multi-object detection
// - iOS 15-16: Person segmentation
// - iOS 13-14: Basic saliency detection
```

### 6. Undo

```swift
// Full edit history:
// - Tap "Undo" button in navigation bar
// - Go back through up to 10 previous states
// - Works for all edits
```

## 🎨 Customization

### Modify Colors

```swift
// In PhotoEditorView, customize:
// - Accent colors
// - Background colors
// - Button styles
// - UI elements
```

### Extend Features

```swift
// Add custom filters:
extension FilterType {
    case myCustomFilter
    
    var displayName: String {
        switch self {
        case .myCustomFilter: return "Custom"
        // ...
        }
    }
}
```

## 🔧 Configuration Options

### Maximum Image Resolution

Default: 4000px on longest side (prevents memory issues)

To change:
```swift
// In saveFinalEditedImage() function
let maxDimension: CGFloat = 6000 // Your preferred max
```

### Undo History Limit

Default: 10 states

To change:
```swift
// In saveToHistory() function
if imageHistory.count > 20 { // Your preferred limit
    imageHistory.removeFirst()
}
```

### Crop Zoom Range

Default: 0.3x - 10x

To change:
```swift
// In MagnificationGesture
imageScale = max(0.1, min(lastScale * scale, 20.0)) // Your range
```

## 📱 iOS Version Features

| Feature | iOS 15 | iOS 16 | iOS 17 |
|---------|--------|--------|--------|
| Text Overlays | ✅ | ✅ | ✅ |
| Crop | ✅ | ✅ | ✅ |
| Filters | ✅ | ✅ | ✅ |
| Blur | ✅ | ✅ | ✅ |
| Selective Blur | ✅ | ✅ | ✅ |
| Undo | ✅ | ✅ | ✅ |
| Remove BG (Person) | ✅ | ✅ | ✅ |
| Remove BG (Advanced) | ❌ | ❌ | ✅ |

## 🏗️ Architecture

```
PhotoEditorKit/
├── Views/
│   ├── PhotoEditorView.swift        # Main editor view
│   ├── DraggableTextView.swift      # Text overlay component
│   ├── CropOverlayView.swift        # Crop grid overlay
│   └── FocusAreaOverlay.swift       # Selective blur overlay
├── Models/
│   ├── EditingTool.swift            # Tool types
│   ├── TextOverlay.swift            # Text model
│   ├── FilterType.swift             # Filter types
│   └── CropAspectRatio.swift        # Crop ratios
├── Utilities/
│   ├── ImagePicker.swift            # UIKit image picker bridge
│   └── BackgroundRemover.swift      # AI background removal
└── Extensions/
    └── UIImage+Extensions.swift     # Helper methods
```

## 🎯 Use Cases

### 1. Social Media App
Add photo editing before posting

### 2. E-commerce App
Let users edit product photos

### 3. Profile Picture Editor
Background removal + crop for perfect avatars

### 4. Messaging App
Add text and stickers to photos

### 5. Photo Gallery App
Full editing suite for users

## ⚡ Performance

- **Memory Efficient**: Auto-scales images to max 4000px
- **Fast Processing**: Optimized Core Image filters
- **Responsive UI**: Smooth 60fps interactions
- **Background Processing**: AI tasks run asynchronously

## 🐛 Known Limitations

1. **High-Res Images**: Very large images (>8000px) are scaled down
2. **iOS 13-14 Background Removal**: Less accurate than newer versions
3. **Undo Limit**: Only 10 states stored (configurable)
4. **Text After Crop**: Text overlays are cleared when cropping

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Built with SwiftUI
- Uses Apple's Vision framework for AI features
- Core Image for filters and effects

## 📝 Changelog

### Version 1.0.0 (2024)
- ✨ Initial release
- 🎨 Text overlays with full customization
- ✂️ Interactive crop with zoom & pan
- 🎭 10+ professional filters
- 🌫️ Blur effects with selective focus
- 🤖 AI background removal (iOS 13+)
- ⏮️ Undo with 10-state history
- 📱 iPhone & iPad support

## 💡 Tips & Tricks

1. **Best Quality**: Use original quality images for best results
2. **Background Removal**: Works best with clear subject-background separation
3. **Selective Blur**: Use for portrait-mode effect on any photo
4. **Crop First**: Apply crop before other edits for better performance
5. **Undo Often**: Don't be afraid to experiment - you can always undo!

## 📚 Documentation & Examples

- **[INTEGRATION_EXAMPLES.md](INTEGRATION_EXAMPLES.md)** - 10+ real-world examples 🔥
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Complete feature documentation

## 🆘 Support

Having issues? Check out:
- [GitHub Issues](https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore/issues)
- [Documentation](https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore/wiki)
- [Repository](https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore)

## 📦 Add as Dependency

To use in your project:
```
URL: https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore
Branch: Stages
```

## 👨‍💻 Developer

**Developed by Noman Belim** 🚀

- 🏢 Organization: [Excelsior Technologies Community](https://github.com/Excelsior-Technologies-Community)
- 📦 Repository: [iOS PhotoEditor](https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore)
- 💼 Developer: [@noman1303](https://github.com/noman1303)

---

**Made for the iOS developer community**

