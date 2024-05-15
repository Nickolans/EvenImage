// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import CoreGraphics
import QuartzCore
import AppKit

fileprivate extension NSColor {
    static var backgroundGray: NSColor {
        return NSColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
    }
    
    static var strokeGray: NSColor {
        return NSColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
    }
}

@available(macOS 13.0, *)
@main
struct EvenImage: ParsableCommand {
    
    @Argument() var imagePath: String
    @Argument() var outputDirectory: String
    @Option() var height = 1200
    @Option() var width = 2800
    
    mutating func run() throws {
        guard let imagePath = relativeUrl(to: self.imagePath) else { return }
        processImage(withPath: "file://\(imagePath.path)")
    }
    
    private func relativeUrl(to path: String) -> URL? {
        let currentPathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return URL(fileURLWithPath: path, relativeTo: currentPathUrl)
    }
    
    private func processImage(withPath path: String) {
        
        guard let url = URL(string: path) else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        let image = NSImage(data: data)!
        
        let context = NSGraphicsContext(cgContext: CGContext(data: nil, width: width, height: height,
                                                         bitsPerComponent: 8,
                                                         bytesPerRow: 0,
                                                         space: CGColorSpaceCreateDeviceRGB(),
                                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!,
                                        flipped: false)
        
        
        /* --- Background --- */
        
        context.cgContext.setFillColor(NSColor.backgroundGray.cgColor)
        context.cgContext.fill([CGRect(x: 0, y: 0, width: width, height: height)])
        
        /* --- Overlay Image --- */
        
        
        var xOff: CGFloat = 0
        var yOff: CGFloat = 0
        
        let widthRatio = CGFloat(width) / image.size.width
        let heightRatio = CGFloat(height) / image.size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        var hostImageWidth = image.size.width * scaleFactor
        var hostImageHeight = image.size.height * scaleFactor
        
        if (CGFloat(width) - hostImageWidth) > 0 {
            xOff = (CGFloat(width) - hostImageWidth) / 2
        }
        
        if (CGFloat(height) - hostImageHeight) > 0 {
            yOff = (CGFloat(height) - hostImageHeight) / 2
        }
        
        print(hostImageWidth, hostImageHeight)
        
        if let cgHostImage = image.cgImage(forProposedRect: nil, context: context, hints: nil) {
            context.cgContext.draw(cgHostImage, in: .init(x: xOff, y: yOff, width: hostImageWidth, height: hostImageHeight), byTiling: false)
        } else {
            print("Image can't be made lol")
        }
        
        context.cgContext.setStrokeColor(NSColor.strokeGray.cgColor)
        context.cgContext.stroke(CGRect(x: 0, y: 0, width: width, height: height), width: 15)
        context.cgContext.saveGState()
        
        print("1...")
        guard let i = context.cgContext.makeImage() else { return }
        let bitImageRep: NSBitmapImageRep = NSBitmapImageRep(cgImage: i)
        let result = bitImageRep.representation(using: .jpeg, properties: [:])
        guard let data = result else { return }
        
        print(FileManager.default.currentDirectoryPath)
        
        let currentPath = FileManager.default.homeDirectoryForCurrentUser
        let path = relativeUrl(to: outputDirectory)!.appending(path: "\(UUID().uuidString).png")
        
        print("SAVING... ", path)
        
        do {
            try data.write(to: path)
        } catch {
            print("ERROR: ", error.localizedDescription)
        }
    }
}
