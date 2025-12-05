# 📘 PhotoEditorKit - Complete Usage Guide

> 💡 **Looking for quick examples?** Check out [INTEGRATION_EXAMPLES.md](INTEGRATION_EXAMPLES.md) for 10+ real-world integration patterns!

## Step-by-Step Integration Guide

### 🎯 Option 1: Swift Package Manager (Recommended)

#### Step 1: Add Package to Your Project

1. Open your Xcode project
2. Click on **File** → **Add Package Dependencies...**
3. In the search bar, paste your repository URL:
   ```
   https://github.com/yourusername/PhotoEditorKit
   ```
4. Select the version rule:
   - **Up to Next Major Version**: `1.0.0` < `2.0.0` (Recommended)
   - **Up to Next Minor Version**: `1.0.0` < `1.1.0`
   - **Exact Version**: `1.0.0`
5. Click **Add Package**
6. Wait for Xcode to fetch and resolve dependencies
7. Select **PhotoEditorKit** from the list
8. Click **Add Package**

#### Step 2: Import in Your Swift File

```swift
import SwiftUI
import PhotoEditorKit  // Add this line
```

#### Step 3: Use the Photo Editor

```swift
struct MyView: View {
    var body: some View {
        PhotoEditorView()  // That's it!
    }
}
```

---

### 🎯 Option 2: Manual Installation

#### Step 1: Download the Source

1. Go to the repository: `https://github.com/yourusername/PhotoEditorKit`
2. Click **Code** → **Download ZIP**
3. Extract the ZIP file

#### Step 2: Copy Files to Your Project

1. In Finder, navigate to the extracted folder
2. Find the `Sources/PhotoEditorKit` folder
3. Drag and drop it into your Xcode project
4. Make sure **"Copy items if needed"** is checked
5. Click **Finish**

#### Step 3: Import and Use

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        PhotoEditorView()
    }
}
```

---

## 💡 Usage Examples

### Example 1: Basic Implementation

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            PhotoEditorView()
        }
    }
}
```

### Example 2: Modal Presentation

```swift
import SwiftUI
import PhotoEditorKit

struct MyApp: View {
    @State private var showPhotoEditor = false
    
    var body: some View {
        VStack {
            Text("My Photo App")
                .font(.largeTitle)
            
            Button("Edit Photo") {
                showPhotoEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $showPhotoEditor) {
            PhotoEditorView()
        }
    }
}
```

### Example 3: Sheet Presentation

```swift
import SwiftUI
import PhotoEditorKit

struct PhotoGalleryView: View {
    @State private var showEditor = false
    
    var body: some View {
        ScrollView {
            // Your photo gallery grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(photos) { photo in
                    Image(photo.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            showEditor = true
                        }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            PhotoEditorView()
        }
    }
}
```

### Example 4: With Navigation Link

```swift
import SwiftUI
import PhotoEditorKit

struct MenuView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Photo Editor") {
                    PhotoEditorView()
                }
                NavigationLink("Gallery") {
                    GalleryView()
                }
                NavigationLink("Settings") {
                    SettingsView()
                }
            }
            .navigationTitle("My App")
        }
    }
}
```

### Example 5: Check iOS Version Features

```swift
import SwiftUI
import PhotoEditorKit

struct FeatureCheckView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Available Features")
                .font(.headline)
            
            if PhotoEditorKit.isAdvancedBackgroundRemovalAvailable {
                Label("Advanced BG Removal", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            if PhotoEditorKit.isPersonSegmentationAvailable {
                Label("Person Segmentation", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            if PhotoEditorKit.isBasicBackgroundRemovalAvailable {
                Label("Basic BG Removal", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            Button("Open Editor") {
                // Show editor
            }
        }
    }
}
```

---

## 🔧 Configuration & Customization

### Custom Info.plist Entries

Add these to your `Info.plist` for photo library access:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to edit images</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save edited photos</string>
```

### SwiftUI App Integration

```swift
import SwiftUI
import PhotoEditorKit

@main
struct MyPhotoApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoEditorView()
        }
    }
}
```

---

## 📱 Platform-Specific Considerations

### iPhone

```swift
struct ContentView: View {
    var body: some View {
        PhotoEditorView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
```

### iPad

```swift
struct ContentView: View {
    var body: some View {
        PhotoEditorView()
            .frame(maxWidth: 800) // Optional: Limit width on iPad
    }
}
```

---

## 🎨 Features Usage

### 1. Text Tool
- Tap "Text" button
- Enter text
- Choose color from palette
- Tap "Add"
- Drag to position
- Pinch to resize
- Double-tap to delete

### 2. Crop Tool
- Tap "Crop" button
- Choose aspect ratio:
  - **Free**: No constraints
  - **Square**: 1:1
  - **4:3**: Standard photo
  - **16:9**: Widescreen
  - **3:2**: Classic 35mm
- Pinch to zoom (0.3x - 10x)
- Drag to reposition
- Tap "Apply Crop"

### 3. Filters
- Tap "Filters" button
- Scroll through filter previews
- Tap a filter to apply
- Adjust intensity slider
- Filters auto-apply

### 4. Blur
- Tap "Blur" button
- Choose style:
  - **Gaussian**: Uniform blur
  - **Motion**: Directional blur
  - **Zoom**: Radial blur
- Adjust blur amount slider
- **Focus Area** (optional):
  - Toggle on "Focus Area"
  - Drag circle to position
  - Pinch to resize
  - Tap "Apply Selective Blur"

### 5. Remove Background
- Tap "Remove BG" button
- Tap "Remove Background"
- Wait for AI processing (1-3 seconds)
- Background automatically removed
- Works on iOS 13+

### 6. Undo
- Tap "Undo" button (top left)
- Goes back one step
- Can undo up to 10 times

### 7. Reset
- Tap "Reset" button (top left)
- Returns to original image
- Clears all edits

### 8. Save
- Tap "Save" button (top right)
- Image saved to Photos app
- Includes all edits and text

---

## 🐛 Troubleshooting

### Package Not Found
1. Check your repository URL
2. Ensure repository is public or you have access
3. Try **File** → **Packages** → **Reset Package Caches**

### Build Errors
1. Clean build folder: **Product** → **Clean Build Folder** (Cmd+Shift+K)
2. Ensure iOS deployment target is 13.0+
3. Check Swift version is 5.9+

### Image Not Saving
1. Check Info.plist has required permissions
2. Test on real device, not simulator
3. Check iOS Settings → Privacy → Photos

### Background Removal Not Working
1. Check iOS version (requires iOS 13+)
2. Try with clear subject-background separation
3. Check console for error messages

### Memory Issues
1. Images are auto-scaled to 4000px max
2. Don't edit extremely large images
3. Close other apps to free memory

---

## 📊 Performance Tips

1. **Image Size**: Images >8000px are automatically scaled
2. **Undo History**: Limited to 10 states to save memory
3. **Background Removal**: Works best with <4000px images
4. **Multiple Edits**: Apply crop first for better performance
5. **Memory**: Close and reopen editor for very large images

---

## 🔐 Privacy & Permissions

### Required Permissions

#### Info.plist Keys

```xml
<!-- Required for opening images -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to edit</string>

<!-- Required for saving images -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save edited photos</string>
```

### Requesting Permissions in Code

```swift
import Photos

func requestPhotoLibraryPermission() {
    PHPhotoLibrary.requestAuthorization { status in
        switch status {
        case .authorized:
            print("Permission granted")
        case .denied, .restricted:
            print("Permission denied")
        case .notDetermined:
            print("Permission not determined")
        case .limited:
            print("Limited permission")
        @unknown default:
            print("Unknown permission status")
        }
    }
}
```

---

## 🎓 Advanced Usage

### Custom Styling

The package uses system colors, so it automatically adapts to light/dark mode and user preferences.

### Localization

Currently English only. Contributions for localization welcome!

### Accessibility

All controls are accessible via VoiceOver and support Dynamic Type.

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/PhotoEditorKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/PhotoEditorKit/discussions)
- **Email**: your.email@example.com

---

## 🔄 Updates

To update to the latest version:

1. Go to **File** → **Packages** → **Update to Latest Package Versions**
2. Or right-click on package → **Update Package**

---

## ✅ Checklist for Integration

- [ ] Add package dependency
- [ ] Add Info.plist permissions
- [ ] Import PhotoEditorKit
- [ ] Test on real device
- [ ] Test all features
- [ ] Test different iOS versions
- [ ] Test light/dark mode
- [ ] Test on iPhone and iPad
- [ ] Add to production app

---

**Need more help?** Check out the [main README](README.md) or [open an issue](https://github.com/noman1303/Excelsior-Technologies-Community-IOS_PhotoEditore/issues)!

---

**Developed by Noman Belim** 🚀

*Empowering iOS developers with powerful photo editing capabilities*

