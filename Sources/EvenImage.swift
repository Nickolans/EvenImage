// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import CoreGraphics
import AppKit

fileprivate extension NSColor {
    static var backgroundGray: NSColor {
        return NSColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
    }
    
    static var strokeGray: NSColor {
        return NSColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
    }
}

fileprivate enum EvenImageError: Error {
    case errorSavingImageFile
    case errorRenderingImage
    case imageUrlInvalid
    case imageDataInvalid
    case imagePathInvalid
    case outputPathInvalid
}

@available(macOS 13.0, *)
@main
struct EvenImage: ParsableCommand {
    
    @Argument() var imagePath: String
    @Argument() var outputDirectory: String
    @Option() var height = 1200
    @Option() var width = 2800
    
    mutating func run() throws {
        guard let imagePath = relativeUrl(to: self.imagePath) else {
            throw EvenImageError.imagePathInvalid
        }
        
        try processImage(withPath: "file://\(imagePath.path)")
    }
    
    private func relativeUrl(to path: String) -> URL? {
        let currentPathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return URL(fileURLWithPath: path, relativeTo: currentPathUrl)
    }
    
    private func processImage(withPath path: String) throws {
        
        guard let url = URL(string: path) else {
            throw EvenImageError.imageUrlInvalid
        }
        
        guard let data = try? Data(contentsOf: url), let image = NSImage(data: data) else {
            throw EvenImageError.imageDataInvalid
        }
        
        let context = NSGraphicsContext(cgContext: CGContext(data: nil, width: width, height: height,
                                                             bitsPerComponent: 8,
                                                             bytesPerRow: 0,
                                                             space: CGColorSpaceCreateDeviceRGB(),
                                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!,
                                        flipped: false)
        
        
        /* --- Background Color --- */
        
        context.cgContext.setFillColor(NSColor.backgroundGray.cgColor)
        context.cgContext.fill([CGRect(x: 0, y: 0, width: width, height: height)])
        
        /* --- Overlay Image --- */
        
        try overlayImage(image, withContext: context)
        
        /* --- Stroke --- */
        
        context.cgContext.setStrokeColor(NSColor.strokeGray.cgColor)
        context.cgContext.stroke(CGRect(x: 0, y: 0, width: width, height: height), width: 15)
        
        try saveImage(withContext: context)
    }
    
    private func overlayImage(_ image: NSImage, withContext context: NSGraphicsContext) throws {
       
        var xOff: CGFloat = 0
        var yOff: CGFloat = 0
        let widthRatio = CGFloat(width) / image.size.width
        let heightRatio = CGFloat(height) / image.size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let hostImageWidth = image.size.width * scaleFactor
        let hostImageHeight = image.size.height * scaleFactor
        
        /* --- Centering Overlay Image --- */
        
        if (CGFloat(width) - hostImageWidth) > 0 {
            xOff = (CGFloat(width) - hostImageWidth) / 2
        }
        
        if (CGFloat(height) - hostImageHeight) > 0 {
            yOff = (CGFloat(height) - hostImageHeight) / 2
        }
        
        guard let cgHostImage = image.cgImage(forProposedRect: nil, context: context, hints: nil) else {
            throw EvenImageError.errorRenderingImage
        }
        
        context.cgContext.draw(cgHostImage, in: .init(x: xOff, y: yOff, width: hostImageWidth, height: hostImageHeight), byTiling: false)
    }
    
    private func saveImage(withContext context: NSGraphicsContext) throws {
        guard let image = context.cgContext.makeImage() else {
            throw EvenImageError.errorRenderingImage
        }
        
        let bitImageRep: NSBitmapImageRep = NSBitmapImageRep(cgImage: image)
        let result = bitImageRep.representation(using: .jpeg, properties: [:])
        
        guard let data = result else {
            throw EvenImageError.errorRenderingImage
        }
        
        guard let path = relativeUrl(to: outputDirectory) else {
            throw EvenImageError.outputPathInvalid
        }
        
        do {
            try data.write(to: path.appending(path: "\(UUID().uuidString).png"))
        } catch {
            throw EvenImageError.errorSavingImageFile
        }
    }
}
