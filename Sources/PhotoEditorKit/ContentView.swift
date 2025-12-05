//
//  ContentView.swift
//  PhotoEditor
//
//  Enhanced Photo Editor with Text, Crop, Filters, and Blur
//

import SwiftUI
import Vision

public struct ContentView: View {
    // Public initializer for package users
    public init() {}
    
    // MARK: - State
    @State private var canvasSize: CGSize = .zero

    @State private var inputImage: UIImage?
    @State private var editedImage: UIImage?
    @State private var imageHistory: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var activeTool: EditingTool? = nil
    @State private var textOverlays: [TextOverlay] = []
    @State private var selectedOverlayId: UUID? = nil
    @State private var newText: String = ""
    @State private var selectedTextColor: Color = .white
    @State private var blurAmount: Double = 0.0
    @State private var useSelectiveBlur: Bool = false
    @State private var focusAreaCenter: CGPoint = .zero
    @State private var focusAreaRadius: CGFloat = 150
    @State private var selectedFilter: FilterType = .none
    @State private var filterIntensity: Double = 1.0
    @State private var cropRect: CGRect = .zero
    @State private var isCropping: Bool = false
    @State private var cropAspectRatio: CropAspectRatio = .free
    @State private var showingColorPicker = false
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    @State private var lastImageOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var showingSaveAlert = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                editorCanvas
                Divider()
                toolBar
            }
            .navigationTitle("Photo Editor")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: HStack {
                    if !imageHistory.isEmpty {
                        Button(action: {
                            undoLastEdit()
                        }) {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                        }
                    }
                    if editedImage != nil || inputImage != nil {
                        Button(action: {
                            resetEditor()
                        }) {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                        }
                    }
                },
                trailing: HStack {
                    if editedImage != nil {
                        Button(action: {
                            saveFinalEditedImage()

                        }) {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Label("Open", systemImage: "photo.on.rectangle")
                    }
                }
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage, onImagePicked: loadImage)
            }
            .alert(isPresented: $showingSaveAlert) {
                Alert(
                    title: Text("Image Saved"),
                    message: Text("Your edited photo has been saved to Photos"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Subviews

    private var editorCanvas: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .onAppear { canvasSize = geometry.size }
                    .onChange(of: geometry.size) { canvasSize = $0 }

                if let uiImage = editedImage ?? inputImage {
                    ZStack {
                        // Main image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(isCropping ? imageScale : 1.0)
                            .offset(isCropping ? imageOffset : .zero)
                            .gesture(
                                isCropping ? 
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            imageOffset = CGSize(
                                                width: lastImageOffset.width + value.translation.width,
                                                height: lastImageOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { _ in 
                                            lastImageOffset = imageOffset 
                                        },
                                    MagnificationGesture()
                                        .onChanged { scale in
                                            // Allow zoom from 0.3x (zoom out) to 10x (zoom in very close)
                                            imageScale = max(0.3, min(lastScale * scale, 10.0))
                                        }
                                        .onEnded { _ in
                                            lastScale = imageScale
                                        }
                                )
                                : nil
                            )

                        // Text overlays
                        ForEach(textOverlays) { overlay in
                            DraggableTextView(
                                overlay: overlay,
                                isSelected: selectedOverlayId == overlay.id,
                                onTap: { selectedOverlayId = overlay.id },
                                onDelete: { deleteOverlay(overlay.id) },
                                onPositionChange: { updateOverlayPosition(overlay.id, position: $0) },
                                onScaleChange: { updateOverlayScale(overlay.id, scale: $0) }
                            )
                        }

                        // Crop overlay
                        if isCropping {
                            CropOverlayView(aspectRatio: cropAspectRatio)
                        }
                        
                        // Focus area overlay for selective blur
                        if useSelectiveBlur && activeTool == .blur {
                            FocusAreaOverlay(
                                center: $focusAreaCenter,
                                radius: $focusAreaRadius
                            )
                        }
                    }
                } else {
                    emptyStateView
                }
            }
            .background(Color.black)
        }
    }

    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Tap \"Open\" to choose a photo")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Add text, apply filters, crop and more")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    private var toolBar: some View {
        VStack(spacing: 12) {
            // Main tools
            
                HStack(spacing: 12) {
                    toolButton(title: "Text", systemImage: "textformat", tool: .text)
                    toolButton(title: "Crop", systemImage: "crop", tool: .crop)
                    toolButton(title: "Filters", systemImage: "camera.filters", tool: .filters)
                    toolButton(title: "Blur", systemImage: "circle.dotted", tool: .blur)
                    toolButton(title: "Remove BG", systemImage: "person.crop.circle.badge.minus", tool: .removeBG)
                }
                .padding(.horizontal)
            

            // Tool-specific controls
            if activeTool != nil {
                Divider()
                toolControls
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var toolControls: some View {
        switch activeTool {
        case .text:
            VStack(spacing: 12) {
                HStack {
                    TextField("Enter text", text: $newText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        showingColorPicker.toggle()
                    } label: {
                        Circle()
                            .fill(selectedTextColor)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                            )
                    }
                    
                    Button("Add") {
                        addTextOverlay()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (editedImage == nil && inputImage == nil))
                }
                
                if showingColorPicker {
                    ColorPickerView(selectedColor: $selectedTextColor)
                }
                
                if selectedOverlayId != nil {
                    HStack {
                        Text("Tap text to select • Double tap to delete")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            
        case .filters:
            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            FilterButton(
                                filter: filter,
                                isSelected: selectedFilter == filter,
                                previewImage: inputImage
                            ) {
                                selectedFilter = filter
                                applyFilter(filter)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                if selectedFilter != .none {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intensity: \(Int(filterIntensity * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $filterIntensity, in: 0...1) { _ in
                            applyFilter(selectedFilter)
                        }
                    }
                }
            }
            
        case .blur:
            VStack(spacing: 12) {
                HStack {
                    Text("Blur Style")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    BlurStyleButton(title: "Gaussian", icon: "circle.dotted") {
                        applyBlur(style: .gaussian)
                    }
                    BlurStyleButton(title: "Motion", icon: "arrow.right") {
                        applyBlur(style: .motion)
                    }
                    BlurStyleButton(title: "Zoom", icon: "arrow.up.left.and.arrow.down.right") {
                        applyBlur(style: .zoom)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount: \(Int(blurAmount))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: $blurAmount, in: 0...25, step: 1)
                }
                
                Divider()
                
                Toggle(isOn: $useSelectiveBlur) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Focus Area")
                            .font(.subheadline)
                        Text("Blur everything except selected area")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: useSelectiveBlur) { newValue in
                    if newValue {
                        // Initialize focus area at center
                        focusAreaCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                    }
                }
                
                if useSelectiveBlur {
                    VStack(spacing: 8) {
                        Text("Drag and pinch the circle to adjust focus area")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Apply Selective Blur") {
                            applySelectiveBlur()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(blurAmount == 0 || (editedImage == nil && inputImage == nil))
                    }
                }
            }
            
        case .crop:
            VStack(spacing: 12) {
                HStack {
                    Text("Aspect Ratio")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CropAspectRatio.allCases, id: \.self) { ratio in
                            CropRatioButton(ratio: ratio, isSelected: cropAspectRatio == ratio) {
                                cropAspectRatio = ratio
                            }
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        cancelCrop()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Apply Crop") {
                        applyCrop()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(editedImage == nil && inputImage == nil)
                }
            }
            
        case .removeBG:
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                Text("Remove Background")
                    .font(.headline)
                
                Text("AI will automatically detect and remove the background from your image")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Remove Background") {
                removeBackground()
            }
            .buttonStyle(.borderedProminent)
            .disabled(editedImage == nil && inputImage == nil)
            
            if #available(iOS 17.0, *) {
                Text("Using Advanced AI (iOS 17+)")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else {
                Text("Using Person Detection (iOS 15+)")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            }
            
        case .none:
            EmptyView()
        }
    }

    private func toolButton(title: String, systemImage: String, tool: EditingTool) -> some View {
        Button {
            if activeTool == tool {
                activeTool = nil
                isCropping = false
            } else {
                activeTool = tool
                isCropping = (tool == .crop)
                if tool == .crop {
                    imageScale = 1.0
                    imageOffset = .zero
                    lastImageOffset = .zero
                    lastScale = 1.0
                }
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(activeTool == tool ? Color.accentColor.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func loadImage(_ image: UIImage?) {
        guard let image = image else { return }
        inputImage = image
        editedImage = image
        imageHistory.removeAll() // Clear history when loading new image
        textOverlays.removeAll()
        selectedOverlayId = nil
        activeTool = nil
        selectedFilter = .none
        blurAmount = 0
        filterIntensity = 1.0
    }
    
    private func saveToHistory() {
        if let current = editedImage {
            imageHistory.append(current)
            // Limit history to last 10 states to avoid memory issues
            if imageHistory.count > 10 {
                imageHistory.removeFirst()
            }
        }
    }
    
    private func undoLastEdit() {
        guard !imageHistory.isEmpty else { return }
        editedImage = imageHistory.removeLast()
        if imageHistory.isEmpty {
            // If we're back to the beginning, restore to input image
            editedImage = inputImage
        }
    }
    
    private func removeBackground() {
        guard let baseImage = editedImage ?? inputImage else { return }
        
        saveToHistory() // Save current state before removing background
        
        print("\n=== REMOVE BACKGROUND STARTED ===")
        
        // Try iOS 17+ API first (most accurate)
        if #available(iOS 17.0, *) {
            print("Using iOS 17+ Advanced Subject Extraction")
            Task {
                do {
                    let processedImage = try await processImageForSubjectExtraction(baseImage)
                    await MainActor.run {
                        editedImage = processedImage
                        print("✓ Background removed successfully (iOS 17+)")
                        print("=== REMOVE BACKGROUND COMPLETED ===\n")
                    }
                } catch {
                    await MainActor.run {
                        print("⚠️ iOS 17+ method failed: \(error.localizedDescription)")
                        print("Trying fallback method...")
                        // Try fallback for iOS 15-16
                        Task {
                            await removeBackgroundFallbackiOS15(baseImage)
                        }
                    }
                }
            }
        } else {
            // Fallback for iOS 15-16 using person segmentation
            print("Using iOS 15+ Person Segmentation (Fallback)")
            Task {
                await removeBackgroundFallbackiOS15(baseImage)
            }
        }
    }
    
    @available(iOS 17.0, *)
    private func processImageForSubjectExtraction(_ image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "PhotoEditor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage"])
        }
        
        // Use VNGenerateForegroundInstanceMaskRequest for subject detection
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        try handler.perform([request])
        
        guard let result = request.results?.first else {
            throw NSError(domain: "PhotoEditor", code: 2, userInfo: [NSLocalizedDescriptionKey: "No subject detected"])
        }
        
        // Create mask from the result
        let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        
        // Apply mask to original image
        let maskedImage = try applyMask(mask, to: cgImage)
        
        return UIImage(cgImage: maskedImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    @available(iOS 17.0, *)
    private func applyMask(_ mask: CVPixelBuffer, to image: CGImage) throws -> CGImage {
        let ciImage = CIImage(cgImage: image)
        let maskImage = CIImage(cvPixelBuffer: mask)
        
        // Scale mask to match image size
        let scaleX = ciImage.extent.width / maskImage.extent.width
        let scaleY = ciImage.extent.height / maskImage.extent.height
        let scaledMask = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Apply mask to create transparent background
        let filter = CIFilter(name: "CIBlendWithMask")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIImage(color: .clear).cropped(to: ciImage.extent), forKey: kCIInputBackgroundImageKey)
        filter.setValue(scaledMask, forKey: kCIInputMaskImageKey)
        
        guard let output = filter.outputImage else {
            throw NSError(domain: "PhotoEditor", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to apply mask"])
        }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else {
            throw NSError(domain: "PhotoEditor", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage"])
        }
        
        return cgImage
    }
    
    // Fallback for iOS 15-16 using Person Segmentation
    private func removeBackgroundFallbackiOS15(_ image: UIImage) async {
        do {
            guard let cgImage = image.cgImage else {
                print("⚠️ Failed to get CGImage")
                return
            }
            
            // Use VNGeneratePersonSegmentationRequest (iOS 15+)
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = .balanced
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            
            guard let result = request.results?.first else {
                print("⚠️ No person detected in image")
                return
            }
            
            // Get the mask (pixelBuffer is not optional)
            let maskBuffer = result.pixelBuffer
            
            // Apply mask to image
            let maskedImage = try applyPixelBufferMask(maskBuffer, to: cgImage)
            
            await MainActor.run {
                editedImage = UIImage(cgImage: maskedImage, scale: image.scale, orientation: image.imageOrientation)
                print("✓ Background removed successfully (iOS 15+ fallback)")
                print("=== REMOVE BACKGROUND COMPLETED ===\n")
            }
        } catch {
            await MainActor.run {
                print("⚠️ iOS 15+ fallback failed: \(error.localizedDescription)")
                print("=== REMOVE BACKGROUND FAILED ===\n")
            }
        }
    }
    
    
    private func applyPixelBufferMask(_ mask: CVPixelBuffer, to image: CGImage) throws -> CGImage {
        let ciImage = CIImage(cgImage: image)
        let maskImage = CIImage(cvPixelBuffer: mask)
        
        // Scale mask to match image size
        let scaleX = ciImage.extent.width / maskImage.extent.width
        let scaleY = ciImage.extent.height / maskImage.extent.height
        let scaledMask = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Invert mask if needed and apply blur for smoother edges
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(scaledMask, forKey: kCIInputImageKey)
        blurFilter.setValue(2.0, forKey: kCIInputRadiusKey)
        
        guard let blurredMask = blurFilter.outputImage else {
            throw NSError(domain: "PhotoEditor", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to blur mask"])
        }
        
        // Apply mask to create transparent background
        let filter = CIFilter(name: "CIBlendWithMask")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIImage(color: .clear).cropped(to: ciImage.extent), forKey: kCIInputBackgroundImageKey)
        filter.setValue(blurredMask, forKey: kCIInputMaskImageKey)
        
        guard let output = filter.outputImage else {
            throw NSError(domain: "PhotoEditor", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to apply mask"])
        }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: ciImage.extent) else {
            throw NSError(domain: "PhotoEditor", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage"])
        }
        
        return cgImage
    }

    private func addTextOverlay() {
        guard !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let overlay = TextOverlay(
            id: UUID(),
            text: newText,
            fontSize: 32,
            color: selectedTextColor,
            position: nil
        )
        textOverlays.append(overlay)
        selectedOverlayId = overlay.id
        print("➕ Text overlay added: '\(newText)' with color: \(selectedTextColor)")
        newText = ""
    }
    
    private func updateOverlayPosition(_ id: UUID, position: CGPoint) {
        if let index = textOverlays.firstIndex(where: { $0.id == id }) {
            textOverlays[index].position = position
            print("📍 Overlay position updated: \(position)")
        }
    }
    
    private func deleteOverlay(_ id: UUID) {
        textOverlays.removeAll { $0.id == id }
        if selectedOverlayId == id {
            selectedOverlayId = nil
        }
    }

    private func applyFilter(_ filterType: FilterType) {
        guard let baseImage = inputImage else { return }
        
        saveToHistory() // Save current state before applying filter
        
        guard filterType != .none else {
            editedImage = baseImage
            return
        }

        let ciImage = CIImage(image: baseImage)
        let context = CIContext()
        
        var outputImage: CIImage?

        switch filterType {
        case .none:
            editedImage = baseImage
            return
        case .sepia:
            if let filter = CIFilter(name: "CISepiaTone") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
                outputImage = filter.outputImage
            }
        case .noir:
            if let filter = CIFilter(name: "CIPhotoEffectNoir") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .chrome:
            if let filter = CIFilter(name: "CIPhotoEffectChrome") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .fade:
            if let filter = CIFilter(name: "CIPhotoEffectFade") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .instant:
            if let filter = CIFilter(name: "CIPhotoEffectInstant") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .mono:
            if let filter = CIFilter(name: "CIPhotoEffectMono") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .process:
            if let filter = CIFilter(name: "CIPhotoEffectProcess") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .tonal:
            if let filter = CIFilter(name: "CIPhotoEffectTonal") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .transfer:
            if let filter = CIFilter(name: "CIPhotoEffectTransfer") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            }
        case .vivid:
            if let filter = CIFilter(name: "CIVibrance") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(filterIntensity * 2, forKey: "inputAmount")
                outputImage = filter.outputImage
            }
        }
        
        if let output = outputImage,
           let cgimg = context.createCGImage(output, from: output.extent) {
            // Preserve the original image orientation to prevent rotation
            editedImage = UIImage(cgImage: cgimg, scale: baseImage.scale, orientation: baseImage.imageOrientation)
        }
    }

    private func applyBlur(style: BlurStyle) {
        guard let baseImage = inputImage else { return }
        
        saveToHistory() // Save current state before applying blur
        
        guard blurAmount > 0 else {
            editedImage = baseImage
            return
        }

        guard let ciImage = CIImage(image: baseImage) else { return }
        let context = CIContext()
        
        var filter: CIFilter?
        
        switch style {
        case .gaussian:
            filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(blurAmount, forKey: kCIInputRadiusKey)
        case .motion:
            filter = CIFilter(name: "CIMotionBlur")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(blurAmount, forKey: kCIInputRadiusKey)
            filter?.setValue(0, forKey: kCIInputAngleKey)
        case .zoom:
            filter = CIFilter(name: "CIZoomBlur")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(blurAmount, forKey: "inputAmount")
            let extent = ciImage.extent
            filter?.setValue(CIVector(x: extent.width / 2, y: extent.height / 2), forKey: kCIInputCenterKey)
        }

        if let output = filter?.outputImage,
           let cgimg = context.createCGImage(output, from: ciImage.extent) {
            // Preserve the original image orientation to prevent rotation
            editedImage = UIImage(cgImage: cgimg, scale: baseImage.scale, orientation: baseImage.imageOrientation)
        }
    }
    
    private func applySelectiveBlur() {
        guard let baseImage = inputImage else { return }
        guard blurAmount > 0 else { return }
        guard let ciImage = CIImage(image: baseImage) else { return }
        
        saveToHistory() // Save current state before applying selective blur
        
        print("\n=== SELECTIVE BLUR STARTED ===")
        let context = CIContext()
        let imageSize = baseImage.size
        
        // Apply Gaussian blur to entire image
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(blurAmount, forKey: kCIInputRadiusKey)
        guard let blurredImage = blurFilter.outputImage else { return }
        
        // Convert focus area from canvas space to image space
        let imageAspect = imageSize.width / imageSize.height
        let canvasAspect = canvasSize.width / canvasSize.height
        
        let displayedImageSize: CGSize
        let displayedImageOrigin: CGPoint
        
        if canvasAspect > imageAspect {
            let height = canvasSize.height
            let width = height * imageAspect
            displayedImageSize = CGSize(width: width, height: height)
            displayedImageOrigin = CGPoint(x: (canvasSize.width - width) / 2, y: 0)
        } else {
            let width = canvasSize.width
            let height = width / imageAspect
            displayedImageSize = CGSize(width: width, height: height)
            displayedImageOrigin = CGPoint(x: 0, y: (canvasSize.height - height) / 2)
        }
        
        // Convert focus center from canvas to image coordinates
        let focusInDisplayed = CGPoint(
            x: focusAreaCenter.x - displayedImageOrigin.x,
            y: focusAreaCenter.y - displayedImageOrigin.y
        )
        
        let scaleToImage = imageSize.width / displayedImageSize.width
        let focusInImage = CGPoint(
            x: focusInDisplayed.x * scaleToImage,
            y: focusInDisplayed.y * scaleToImage
        )
        let radiusInImage = focusAreaRadius * scaleToImage
        
        print("Focus center in image: \(focusInImage)")
        print("Focus radius in image: \(radiusInImage)")
        
        // Create a radial gradient mask
        let gradientFilter = CIFilter(name: "CIRadialGradient")!
        gradientFilter.setValue(CIVector(x: focusInImage.x, y: focusInImage.y), forKey: "inputCenter")
        gradientFilter.setValue(radiusInImage * 0.7, forKey: "inputRadius0") // Sharp area
        gradientFilter.setValue(radiusInImage * 1.2, forKey: "inputRadius1") // Transition
        gradientFilter.setValue(CIColor.white, forKey: "inputColor0")
        gradientFilter.setValue(CIColor.black, forKey: "inputColor1")
        
        guard var maskImage = gradientFilter.outputImage else { return }
        maskImage = maskImage.cropped(to: ciImage.extent)
        
        // Blend original and blurred using the mask
        let blendFilter = CIFilter(name: "CIBlendWithMask")!
        blendFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blendFilter.setValue(blurredImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        guard let output = blendFilter.outputImage,
              let cgimg = context.createCGImage(output, from: ciImage.extent) else {
            print("⚠️ Failed to create selective blur")
            return
        }
        
        editedImage = UIImage(cgImage: cgimg, scale: baseImage.scale, orientation: baseImage.imageOrientation)
        print("✓ Selective blur applied")
        print("=== SELECTIVE BLUR COMPLETED ===\n")
    }

    private func applyCrop() {
        guard let baseImage = editedImage ?? inputImage else { return }
        guard let ciImage = CIImage(image: baseImage) else { return }
        
        saveToHistory() // Save current state before cropping
        
        let imageSize = baseImage.size
        print("\n=== CROP STARTED ===")
        print("Original image size: \(imageSize)")
        print("Canvas size: \(canvasSize)")
        print("User scale: \(imageScale)")
        print("User offset: \(imageOffset)")
        
        // Calculate how the image is displayed in the canvas (scaledToFit)
        let imageAspect = imageSize.width / imageSize.height
        let canvasAspect = canvasSize.width / canvasSize.height
        
        let displayedImageSize: CGSize
        let displayedImageOrigin: CGPoint
        
        if canvasAspect > imageAspect {
            // Canvas is wider - image is constrained by height
            let height = canvasSize.height
            let width = height * imageAspect
            displayedImageSize = CGSize(width: width, height: height)
            displayedImageOrigin = CGPoint(x: (canvasSize.width - width) / 2, y: 0)
        } else {
            // Canvas is taller - image is constrained by width
            let width = canvasSize.width
            let height = width / imageAspect
            displayedImageSize = CGSize(width: width, height: height)
            displayedImageOrigin = CGPoint(x: 0, y: (canvasSize.height - height) / 2)
        }
        
        print("Displayed image size: \(displayedImageSize)")
        print("Displayed image origin: \(displayedImageOrigin)")
        
        // Calculate the crop overlay size (with padding)
        let cropOverlayRect = calculateCropOverlayRect(in: canvasSize)
        print("Crop overlay rect: \(cropOverlayRect)")
        
        let cropInImageSpace = CGRect(
            x: cropOverlayRect.origin.x - displayedImageOrigin.x,
            y: cropOverlayRect.origin.y - displayedImageOrigin.y,
            width: cropOverlayRect.width,
            height: cropOverlayRect.height
        )
        
        // Account for user's scale and offset
        // The image was scaled and moved, so we need to reverse that
        let scaledCropRect = CGRect(
            x: (cropInImageSpace.origin.x - imageOffset.width) / imageScale,
            y: (cropInImageSpace.origin.y - imageOffset.height) / imageScale,
            width: cropInImageSpace.width / imageScale,
            height: cropInImageSpace.height / imageScale
        )
        
        // Convert to original image coordinates
        let scaleToOriginal = imageSize.width / displayedImageSize.width
        let finalCropRect = CGRect(
            x: scaledCropRect.origin.x * scaleToOriginal,
            y: scaledCropRect.origin.y * scaleToOriginal,
            width: scaledCropRect.width * scaleToOriginal,
            height: scaledCropRect.height * scaleToOriginal
        )
        
        print("Final crop rect in image space: \(finalCropRect)")
        
        // Clamp to image bounds
        let clampedRect = finalCropRect.intersection(CGRect(origin: .zero, size: imageSize))
        print("Clamped crop rect: \(clampedRect)")
        
        // Perform the crop
        let cropped = ciImage.cropped(to: clampedRect)
        let context = CIContext()
        
        if let cgimg = context.createCGImage(cropped, from: cropped.extent) {
            // Preserve the original image orientation to prevent rotation
            let croppedImage = UIImage(cgImage: cgimg, scale: baseImage.scale, orientation: baseImage.imageOrientation)
            editedImage = croppedImage
            inputImage = croppedImage
            
            // Clear text overlays since they would be positioned for the old image
            textOverlays.removeAll()
            selectedOverlayId = nil
            
            print("✓ Cropped to size: \(croppedImage.size)")
        } else {
            print("⚠️ Failed to create CGImage")
        }
        
        print("=== CROP COMPLETED ===\n")

        isCropping = false
        activeTool = nil
        imageScale = 1.0
        imageOffset = .zero
        lastImageOffset = .zero
        lastScale = 1.0
    }
    
    private func calculateCropOverlayRect(in size: CGSize) -> CGRect {
        let padding: CGFloat = 40
        let availableWidth = size.width - 2 * padding
        let availableHeight = size.height - 2 * padding
        
        let width: CGFloat
        let height: CGFloat
        
        if cropAspectRatio == .free || cropAspectRatio == .original {
            // Free crop - use all available space
            width = availableWidth
            height = availableHeight
        } else {
            // Fixed aspect ratio - fit within available space
            let targetRatio = cropAspectRatio.aspectRatio
            let availableRatio = availableWidth / availableHeight
            if availableRatio > targetRatio {
                height = availableHeight
                width = height * targetRatio
            } else {
                width = availableWidth
                height = width / targetRatio
            }
        }
        
        return CGRect(
            x: (size.width - width) / 2,
            y: (size.height - height) / 2,
            width: width,
            height: height
        )
    }
    
    private func cancelCrop() {
        isCropping = false
        activeTool = nil
        imageScale = 1.0
        imageOffset = .zero
        lastImageOffset = .zero
        lastScale = 1.0
    }
    
    private func resetEditor() {
        editedImage = inputImage
        textOverlays.removeAll()
        selectedOverlayId = nil
        activeTool = nil
        selectedFilter = .none
        blurAmount = 0
        filterIntensity = 1.0
        isCropping = false
    }
    
    private func saveImage() {
        guard let image = editedImage else { return }
        
        // Render the final image with text overlays
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let finalImage = renderer.image { context in
            image.draw(at: .zero)
            
            // Draw text overlays
            for overlay in textOverlays {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: overlay.fontSize),
                    .foregroundColor: UIColor(overlay.color)
                ]
                
                let text = overlay.text as NSString
                let size = text.size(withAttributes: attributes)
                let position = overlay.position ?? CGPoint(x: image.size.width / 2, y: image.size.height / 2)
                let rect = CGRect(
                    x: position.x - size.width / 2,
                    y: position.y - size.height / 2,
                    width: size.width,
                    height: size.height
                )
                
                text.draw(in: rect, withAttributes: attributes)
            }
        }
        
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
        showingSaveAlert = true
    }
    private func updateOverlayScale(_ id: UUID, scale: CGFloat) {
        if let index = textOverlays.firstIndex(where: { $0.id == id }) {
            textOverlays[index].scale = scale
        }
    }
    private func saveFinalEditedImage() {
        print("=== SAVE IMAGE STARTED ===")
        print("Canvas size: \(canvasSize)")
        print("Number of text overlays: \(textOverlays.count)")
        
        if canvasSize.width == 0 || canvasSize.height == 0 {
            print("ERROR: Canvas size is zero")
            return
        }

        guard let base = editedImage ?? inputImage else {
            print("ERROR: No image to save")
            return
        }

        let originalSize = base.size
        print("Original image size: \(originalSize)")
        
        // Limit output size to avoid memory issues
        // Max dimension of 4000 pixels (16MP max, which is reasonable for most uses)
        let maxDimension: CGFloat = 4000
        let scale: CGFloat
        let imageSize: CGSize
        
        if originalSize.width > maxDimension || originalSize.height > maxDimension {
            let widthScale = maxDimension / originalSize.width
            let heightScale = maxDimension / originalSize.height
            scale = min(widthScale, heightScale)
            imageSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
            print("Scaling down image to: \(imageSize) (scale: \(scale))")
        } else {
            scale = 1.0
            imageSize = originalSize
            print("Using original size: \(imageSize)")
        }
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let finalImage = renderer.image { ctx in
            // Draw base image at scaled size
            base.draw(in: CGRect(origin: .zero, size: imageSize))
            print("Base image drawn at size: \(imageSize)")

            // Calculate the displayed image frame within the canvas (accounting for scaledToFit)
            let imageAspect = imageSize.width / imageSize.height
            let canvasAspect = canvasSize.width / canvasSize.height
            
            let displayedImageSize: CGSize
            let displayedImageOrigin: CGPoint
            
            if canvasAspect > imageAspect {
                // Canvas is wider - image is constrained by height
                let height = canvasSize.height
                let width = height * imageAspect
                displayedImageSize = CGSize(width: width, height: height)
                displayedImageOrigin = CGPoint(x: (canvasSize.width - width) / 2, y: 0)
            } else {
                // Canvas is taller - image is constrained by width
                let width = canvasSize.width
                let height = width / imageAspect
                displayedImageSize = CGSize(width: width, height: height)
                displayedImageOrigin = CGPoint(x: 0, y: (canvasSize.height - height) / 2)
            }
            
            print("Displayed image size: \(displayedImageSize)")
            print("Displayed image origin: \(displayedImageOrigin)")

            // Draw text overlays
            for (index, overlay) in textOverlays.enumerated() {
                print("\n--- Text overlay \(index + 1): '\(overlay.text)' ---")
                
                // Calculate scale factor from displayed size to output image size
                let imageToDisplayScale = imageSize.width / displayedImageSize.width
                
                // Calculate final font size - scale the screen font size to match output resolution
                // But cap at 400pt to avoid memory issues
                let screenFontSize = overlay.fontSize * overlay.scale
                let outputFontSize = min(screenFontSize * imageToDisplayScale, 400)
                
                let font = UIFont.boldSystemFont(ofSize: outputFontSize)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor(overlay.color),
                    .paragraphStyle: paragraphStyle
                ]

                let text = overlay.text as NSString
                
                // Get the text bounding box
                let textBoundingRect = text.boundingRect(
                    with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    attributes: attributes,
                    context: nil
                )
                print("Text bounds: \(textBoundingRect.size)")

                // Get canvas-space position (this is where user placed the center of the text)
                let canvasPoint = overlay.position ?? CGPoint(
                    x: canvasSize.width / 2,
                    y: canvasSize.height / 2
                )

                // Convert from canvas space to displayed image space
                let displayedImagePoint = CGPoint(
                    x: canvasPoint.x - displayedImageOrigin.x,
                    y: canvasPoint.y - displayedImageOrigin.y
                )

                // Convert from displayed image space to output image space
                let imagePoint = CGPoint(
                    x: displayedImagePoint.x * imageToDisplayScale,
                    y: displayedImagePoint.y * imageToDisplayScale
                )
                print("Center point in output: \(imagePoint)")

                // Calculate top-left corner for drawing (center the text on imagePoint)
                let drawPoint = CGPoint(
                    x: imagePoint.x - textBoundingRect.width / 2,
                    y: imagePoint.y - textBoundingRect.height / 2
                )
                
                // Create draw rect
                let drawRect = CGRect(
                    x: drawPoint.x,
                    y: drawPoint.y,
                    width: textBoundingRect.width,
                    height: textBoundingRect.height
                )
                
                // Check if text is within image bounds
                let imageBounds = CGRect(origin: .zero, size: imageSize)
                if !imageBounds.intersects(drawRect) {
                    print("⚠️ Text is outside bounds, skipping")
                    continue
                }
                
                // Draw text centered in the rect
                text.draw(
                    with: drawRect,
                    options: [.usesLineFragmentOrigin],
                    attributes: attributes,
                    context: nil
                )
                print("✓ Text drawn at \(drawRect)")
            }
            
            print("\n=== All overlays processed ===")
        }

        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
        print("Image saved to photo album")
        print("=== SAVE IMAGE COMPLETED ===\n")
        showingSaveAlert = true
    }


    private func convertPointFromCanvasToImage(_ point: CGPoint, imageSize: CGSize) -> CGPoint {
        let scaleX = imageSize.width / canvasSize.width
        let scaleY = imageSize.height / canvasSize.height

        return CGPoint(
            x: point.x * scaleX,
            y: point.y * scaleY
        )
    }
    private var canvasContent: some View {
        ZStack {
            if let uiImage = editedImage ?? inputImage {
                // Image + overlays
            } else {
                emptyStateView
            }
        }
    }

}

// MARK: - Supporting Views

struct DraggableTextView: View {
    let overlay: TextOverlay
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onPositionChange: (CGPoint) -> Void
    let onScaleChange: (CGFloat) -> Void   // NEW CALLBACK

    @State private var position: CGPoint = .zero
    @State private var lastPosition: CGPoint = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        Text(overlay.text)
            .font(.system(size: overlay.fontSize * scale, weight: .bold))
            .foregroundStyle(overlay.color)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .position(position)
            .gesture(
                SimultaneousGesture(
                    dragGesture,
                    magnificationGesture
                )
            )
            .onTapGesture { onTap() }
            .onTapGesture(count: 2) { onDelete() }
            .onAppear {
                if let savedPos = overlay.position {
                    position = savedPos
                    lastPosition = savedPos
                } else {
                    position = CGPoint(x: 200, y: 200)
                    lastPosition = position
                    // Update the model with the initial position
                    onPositionChange(position)
                }
                scale = overlay.scale
                lastScale = overlay.scale
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                position = CGPoint(
                    x: lastPosition.x + value.translation.width,
                    y: lastPosition.y + value.translation.height
                )
            }
            .onEnded { _ in
                lastPosition = position
                onPositionChange(position)
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
                onScaleChange(scale)
            }
    }
}



struct ColorPickerView: View {
    @Binding var selectedColor: Color
    
    let colors: [Color] = [
        .white, .black, .red, .orange, .yellow,
        .green, .blue, .purple, .pink, .brown
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(selectedColor == color ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: selectedColor == color ? 3 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FilterButton: View {
    let filter: FilterType
    let isSelected: Bool
    let previewImage: UIImage?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if let preview = previewImage {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                }
                
                Text(filter.displayName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

struct BlurStyleButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

struct CropRatioButton: View {
    let ratio: CropAspectRatio
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(isSelected ? Color.accentColor : Color.secondary, lineWidth: 2)
                    .aspectRatio(ratio.aspectRatio, contentMode: .fit)
                    .frame(height: 40)
                
                Text(ratio.displayName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CropOverlayView: View {
    let aspectRatio: CropAspectRatio
    
    var body: some View {
        GeometryReader { geometry in
            let rect = calculateCropRect(in: geometry.size)
            
            ZStack {
                // Dimmed areas
                Color.black.opacity(0.5)
                
                // Crop area (clear)
                Rectangle()
                    .frame(width: rect.width, height: rect.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            
            // Grid overlay
            Rectangle()
                .strokeBorder(Color.white, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            // Grid lines
            Path { path in
                let x1 = (geometry.size.width - rect.width) / 2 + rect.width / 3
                let x2 = (geometry.size.width - rect.width) / 2 + 2 * rect.width / 3
                let y1 = (geometry.size.height - rect.height) / 2 + rect.height / 3
                let y2 = (geometry.size.height - rect.height) / 2 + 2 * rect.height / 3
                
                path.move(to: CGPoint(x: x1, y: (geometry.size.height - rect.height) / 2))
                path.addLine(to: CGPoint(x: x1, y: (geometry.size.height + rect.height) / 2))
                
                path.move(to: CGPoint(x: x2, y: (geometry.size.height - rect.height) / 2))
                path.addLine(to: CGPoint(x: x2, y: (geometry.size.height + rect.height) / 2))
                
                path.move(to: CGPoint(x: (geometry.size.width - rect.width) / 2, y: y1))
                path.addLine(to: CGPoint(x: (geometry.size.width + rect.width) / 2, y: y1))
                
                path.move(to: CGPoint(x: (geometry.size.width - rect.width) / 2, y: y2))
                path.addLine(to: CGPoint(x: (geometry.size.width + rect.width) / 2, y: y2))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
    
    private func calculateCropRect(in size: CGSize) -> CGRect {
        let padding: CGFloat = 40
        let availableWidth = size.width - 2 * padding
        let availableHeight = size.height - 2 * padding
        
        let width: CGFloat
        let height: CGFloat
        
        if aspectRatio == .free || aspectRatio == .original {
            // Free crop - use all available space
            width = availableWidth
            height = availableHeight
        } else {
            // Fixed aspect ratio - fit within available space
            let targetRatio = aspectRatio.aspectRatio
            let availableRatio = availableWidth / availableHeight
            if availableRatio > targetRatio {
                height = availableHeight
                width = height * targetRatio
            } else {
                width = availableWidth
                height = width / targetRatio
            }
        }
        
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
}

struct FocusAreaOverlay: View {
    @Binding var center: CGPoint
    @Binding var radius: CGFloat
    
    @State private var lastCenter: CGPoint = .zero
    @State private var lastRadius: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Dimmed overlay (everything blurred)
            Color.black.opacity(0.4)
            
            // Focus area (clear circle - this stays sharp)
            Circle()
                .fill(Color.clear)
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        
        // Interactive focus circle
        Circle()
            .strokeBorder(Color.white, lineWidth: 3)
            .background(Circle().fill(Color.white.opacity(0.1)))
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            center = CGPoint(
                                x: lastCenter.x + value.translation.width,
                                y: lastCenter.y + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastCenter = center
                        },
                    MagnificationGesture()
                        .onChanged { scale in
                            radius = max(50, min(lastRadius * scale, 300))
                        }
                        .onEnded { _ in
                            lastRadius = radius
                        }
                )
            )
            .onAppear {
                lastCenter = center
                lastRadius = radius
            }
        
        // Helper text
        VStack {
            Spacer()
            Text("Drag to move • Pinch to resize")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                .padding(.bottom, 20)
        }
    }
}

// MARK: - Models & Helpers

enum EditingTool {
    case text
    case crop
    case filters
    case blur
    case removeBG
}

struct TextOverlay: Identifiable {
    let id: UUID
    var text: String
    var fontSize: CGFloat
    var color: Color
    var position: CGPoint?
    var scale: CGFloat = 1.0   // required for pinch zoom
}


enum FilterType: CaseIterable {
    case none
    case sepia
    case noir
    case chrome
    case fade
    case instant
    case mono
    case process
    case tonal
    case transfer
    case vivid
    
    var displayName: String {
        switch self {
        case .none: return "Original"
        case .sepia: return "Sepia"
        case .noir: return "Noir"
        case .chrome: return "Chrome"
        case .fade: return "Fade"
        case .instant: return "Instant"
        case .mono: return "Mono"
        case .process: return "Process"
        case .tonal: return "Tonal"
        case .transfer: return "Transfer"
        case .vivid: return "Vivid"
        }
    }
}

enum BlurStyle {
    case gaussian
    case motion
    case zoom
}

enum CropAspectRatio: CaseIterable {
    case free
    case original
    case square
    case ratio4_3
    case ratio16_9
    case ratio3_2
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .original: return "Original"
        case .square: return "Square"
        case .ratio4_3: return "4:3"
        case .ratio16_9: return "16:9"
        case .ratio3_2: return "3:2"
        }
    }
    
    var aspectRatio: CGFloat {
        switch self {
        case .free: return 1.0 // Not used for free crop
        case .original: return 1.0
        case .square: return 1.0
        case .ratio4_3: return 4.0 / 3.0
        case .ratio16_9: return 16.0 / 9.0
        case .ratio3_2: return 3.0 / 2.0
        }
    }
}

#Preview {
    ContentView()
}
