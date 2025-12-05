# 🔧 PhotoEditorKit - Integration Examples

Complete examples showing how to integrate PhotoEditorKit into your iOS projects.

**Developed by Noman Belim** 🚀

---

## 📦 Prerequisites

1. Add PhotoEditorKit package:
```
URL: https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore
Branch: Stages
Minimum iOS: 15.0
```

2. Add to Info.plist:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to edit</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save edited photos</string>
```

---

## Example 1: Basic Standalone Photo Editor

Simplest possible integration - just the photo editor.

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    var body: some View {
        PhotoEditorView()
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Use Case:** Simple photo editing app

---

## Example 2: Modal Photo Editor

Open photo editor in a sheet/modal.

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    @State private var showPhotoEditor = false
    
    var body: some View {
        VStack {
            Text("My App")
                .font(.largeTitle)
            
            Button("Open Photo Editor") {
                showPhotoEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showPhotoEditor) {
            PhotoEditorView()
        }
    }
}
```

**Use Case:** Add photo editing as a feature in existing app

---

## Example 3: Full Screen Photo Editor

Open in full screen with custom close button.

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    @State private var showPhotoEditor = false
    
    var body: some View {
        VStack {
            Button("Edit Photo") {
                showPhotoEditor = true
            }
        }
        .fullScreenCover(isPresented: $showPhotoEditor) {
            NavigationView {
                PhotoEditorView()
                    .navigationBarItems(trailing: Button("Done") {
                        showPhotoEditor = false
                    })
            }
        }
    }
}
```

**Use Case:** Immersive editing experience

---

## Example 4: Integration with Toast Notifications

Combine PhotoEditorKit with notification system.

```swift
import SwiftUI
import PhotoEditorKit

struct ContentView: View {
    @EnvironmentObject var toast: ToastManager
    @State private var showPhotoEditor = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("My App")
                .font(.title)
            
            Button("🎨 Open Photo Editor") {
                showPhotoEditor = true
                toast.show(.info, "Opening photo editor...")
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $showPhotoEditor) {
            NavigationView {
                PhotoEditorView()
                    .navigationBarItems(trailing: Button("Done") {
                        showPhotoEditor = false
                        toast.show(.success, "Photo editor closed")
                    })
            }
        }
    }
}

@main
struct MyApp: App {
    @StateObject var toast = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toast)
                .overlay(
                    ToastView()
                        .environmentObject(toast)
                )
        }
    }
}
```

**Use Case:** App with toast notifications + photo editing

---

## Example 5: Photo Gallery with Editor

Edit photos from a gallery.

```swift
import SwiftUI
import PhotoEditorKit

struct Photo: Identifiable {
    let id = UUID()
    let name: String
}

struct GalleryView: View {
    @State private var photos = [
        Photo(name: "photo1"),
        Photo(name: "photo2"),
        Photo(name: "photo3")
    ]
    @State private var showPhotoEditor = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(photos) { photo in
                        Image(photo.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .onTapGesture {
                                showPhotoEditor = true
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Photo Gallery")
            .sheet(isPresented: $showPhotoEditor) {
                PhotoEditorView()
            }
        }
    }
}
```

**Use Case:** Photo gallery app with editing

---

## Example 6: Navigation-Based Flow

Use with NavigationLink.

```swift
import SwiftUI
import PhotoEditorKit

struct MenuView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Features") {
                    NavigationLink("📸 Photo Editor") {
                        PhotoEditorView()
                    }
                    
                    NavigationLink("🖼️ Gallery") {
                        Text("Gallery View")
                    }
                    
                    NavigationLink("⚙️ Settings") {
                        Text("Settings View")
                    }
                }
            }
            .navigationTitle("My App")
        }
    }
}
```

**Use Case:** App with multiple sections including photo editor

---

## Example 7: Custom Toolbar Integration

Add custom toolbar around the editor.

```swift
import SwiftUI
import PhotoEditorKit

struct CustomPhotoEditorView: View {
    @State private var showInfo = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom top bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
                
                Spacer()
                
                Text("My Photo Editor")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // PhotoEditorKit
            PhotoEditorView()
        }
        .alert("Photo Editor Help", isPresented: $showInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Use the tools below to edit your photos")
        }
    }
}
```

**Use Case:** Custom branded photo editor

---

## Example 8: With Analytics Tracking

Track usage with analytics.

```swift
import SwiftUI
import PhotoEditorKit

struct AnalyticsPhotoEditor: View {
    @State private var showPhotoEditor = false
    
    var body: some View {
        Button("Edit Photo") {
            // Track event
            Analytics.logEvent("photo_editor_opened")
            showPhotoEditor = true
        }
        .sheet(isPresented: $showPhotoEditor) {
            PhotoEditorView()
                .onDisappear {
                    // Track close event
                    Analytics.logEvent("photo_editor_closed")
                }
        }
    }
}
```

**Use Case:** Track user engagement with photo editing

---

## Example 9: Social Media App Integration

Photo editor before posting.

```swift
import SwiftUI
import PhotoEditorKit

struct PostCreationView: View {
    @State private var showPhotoEditor = false
    @State private var caption = ""
    
    var body: some View {
        VStack {
            // Photo editor preview
            Button("Add Photo") {
                showPhotoEditor = true
            }
            
            // Caption input
            TextField("Write a caption...", text: $caption)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            // Post button
            Button("Post") {
                // Post with edited photo
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showPhotoEditor) {
            PhotoEditorView()
        }
    }
}
```

**Use Case:** Instagram/Twitter-like app

---

## Example 10: E-commerce Product Photo Editor

Let users edit product photos before listing.

```swift
import SwiftUI
import PhotoEditorKit

struct ProductListingView: View {
    @State private var showPhotoEditor = false
    @State private var productName = ""
    @State private var price = ""
    
    var body: some View {
        Form {
            Section("Product Photo") {
                Button("📸 Add/Edit Photo") {
                    showPhotoEditor = true
                }
            }
            
            Section("Details") {
                TextField("Product Name", text: $productName)
                TextField("Price", text: $price)
            }
            
            Section {
                Button("List Product") {
                    // Submit listing
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $showPhotoEditor) {
            PhotoEditorView()
        }
    }
}
```

**Use Case:** Marketplace/e-commerce app

---

## 🎯 Common Integration Patterns

### Pattern 1: Button Trigger
```swift
Button("Edit") {
    showPhotoEditor = true
}
.sheet(isPresented: $showPhotoEditor) {
    PhotoEditorView()
}
```

### Pattern 2: Navigation Link
```swift
NavigationLink("Photo Editor") {
    PhotoEditorView()
}
```

### Pattern 3: Programmatic Navigation
```swift
NavigationStack {
    // Your content
}
.navigationDestination(isPresented: $showEditor) {
    PhotoEditorView()
}
```

---

## 💡 Tips & Best Practices

### 1. Choose Presentation Style
- **`.sheet()`** - For quick edits, user can dismiss
- **`.fullScreenCover()`** - For immersive editing experience
- **`NavigationLink`** - For app with multiple sections

### 2. Add Custom Close Button
```swift
.navigationBarItems(trailing: Button("Done") {
    dismiss()
})
```

### 3. Handle Saved Images
```swift
// PhotoEditorKit automatically saves to Photos
// Show confirmation toast/alert if needed
```

### 4. Combine with Notifications
```swift
.onReceive(NotificationCenter.default.publisher(...)) {
    // React to events
}
```

---

## 🚀 Next Steps

1. **Choose an example** that fits your app
2. **Copy the code** to your project
3. **Customize** as needed
4. **Build and test!**

---

## 📚 Related Documentation

- [README.md](README.md) - Full documentation
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [USAGE_GUIDE.md](USAGE_GUIDE.md) - Detailed usage

---

**Questions?** Open an issue on [GitHub](https://github.com/Excelsior-Technologies-Community/Excelsior-Technologies-Community-IOS_PhotoEditore/issues)

---

**Made  by Noman Belim** 

*Empowering iOS developers with powerful photo editing tools* 🚀

