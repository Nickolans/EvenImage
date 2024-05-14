// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import CoreGraphics
import QuartzCore
import AppKit

//swift run EvenImage ../ ../

@main
struct EvenImage: ParsableCommand {
    
    @Argument() var imagePath: String
    @Argument() var outputPath: String
    
    mutating func run() throws {
        print("STARTING...")
        
        let context = NSGraphicsContext(cgContext: CGContext(data: nil, width: 750, height: 300,
                                                         bitsPerComponent: 8,
                                                         bytesPerRow: 0,
                                                         space: CGColorSpaceCreateDeviceRGB(),
                                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!,
                                        flipped: false)
        
        context.cgContext.setFillColor(NSColor.blue.cgColor)
        context.cgContext.saveGState()
        context.cgContext.fill([CGRect(x: 0, y: 0, width: 500, height: 500)])
        
        print("1...")
        guard let i = context.cgContext.makeImage() else { return }
        let bitImageRep: NSBitmapImageRep = NSBitmapImageRep(cgImage: i)
        let result = bitImageRep.representation(using: .jpeg, properties: [:])
        guard let data = result else { return }
        
        let currentPath = FileManager.default.homeDirectoryForCurrentUser
        if #available(macOS 13.0, *) {
            let path = currentPath.appending(path: "\(UUID().uuidString).jpg")
            
            print("PATH: ", path)
            
            do {
                try data.write(to: path)
            } catch {
                print("ERROR: ", error.localizedDescription)
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        
        print("Hello, world!", imagePath)
    }
}
