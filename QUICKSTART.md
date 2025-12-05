# ⚡ Quick Start Guide - PhotoEditorKit

Get up and running in 5 minutes!

## 🚀 Installation (30 seconds)

### In Xcode:
1. **File** → **Add Package Dependencies...**
2. Paste URL: `https://github.com/yourusername/PhotoEditorKit`
3. Click **Add Package**
4. Done! ✅

## 💻 Basic Usage (1 minute)

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    var body: some View {
        PhotoEditorView()
    }
}
```

That's it! You now have a full-featured photo editor! 🎉

## 📱 Required Setup

Add to your `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to edit</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save edited photos</string>
```

## ✨ What You Get

- ✅ Text overlays with colors
- ✅ Interactive crop with zoom
- ✅ 10+ professional filters  
- ✅ Blur effects
- ✅ AI background removal
- ✅ Undo/Redo
- ✅ Save to Photos

## 🎯 Common Use Cases

### As Main View
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoEditorView()
        }
    }
}
```

### As Modal
```swift
Button("Edit Photo") {
    showEditor = true
}
.sheet(isPresented: $showEditor) {
    PhotoEditorView()
}
```

### In Navigation
```swift
NavigationLink("Photo Editor") {
    PhotoEditorView()
}
```

## 📚 Learn More

- [Full Documentation](README.md)
- [Detailed Usage Guide](USAGE_GUIDE.md)
- [GitHub Repository](https://github.com/yourusername/PhotoEditorKit)

## 🆘 Need Help?

- [Issues](https://github.com/yourusername/PhotoEditorKit/issues)
- Email: your.email@example.com

---

**Ready to build something amazing? Let's go! 🚀**

