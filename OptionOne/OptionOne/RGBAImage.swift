import UIKit
import Foundation


public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}

/*
 * Reference:
 * https://blog.avenuecode.com/how-to-use-uikit-for-low-level-image-processing-in-swift
 */
public struct RGBAImage {
    public var imageData:UnsafeMutablePointer<Pixel>?
    public var pixels:UnsafeMutableBufferPointer<Pixel>
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        
        // Redraw image for correct pixel format
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bytesPerRow = width * 4
        
        //UnsafeMutablePointer<T>.alloc(sizeof(T))
        imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width*height)
        
        //guard let imageContext = CGBitmapContextCreate(imageData, width, height, 8, bytesPerRow, colorSpace, bitmapInfo) else { return nil }
        guard let imageContext = CGContext(
            data: imageData,
             width: width,
             height: height,
             bitsPerComponent: 8,
             bytesPerRow: bytesPerRow,
             space: colorSpace,
             bitmapInfo: bitmapInfo
        ) else { return nil }
        
        //CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage)
        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        
       // imageData.destroy()
       // imageData.dealloc(width * height)
    }
    
    public func toUIImage() -> UIImage? {
        //guard let newCGImage = context.makeImage() else { return nil }
        //return UIImage(cgImage: newCGImage)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let bytesPerRow = width * 4
        //let imageDataReference = UnsafeMutableRawPointer(imageData)
       /*
        defer {
            imageDataReference.destroy()
        }*/
        //let imageContext = CGBitmapContextCreateWithData(imageDataReference, width, height, 8, bytesPerRow, colorSpace, bitmapInfo, nil, nil)
        guard let imageContext = CGContext(
             data: pixels.baseAddress,
             width: width,
             height: height,
             bitsPerComponent: 8,
             bytesPerRow: bytesPerRow,
             space: colorSpace,
             bitmapInfo: bitmapInfo
        ) else { return nil }
        
        guard let newImage = imageContext.makeImage() else { return nil }
        //guard let cgImage = CGBitmapContextCreateImage(imageContext) else {return nil}
        let image = UIImage( cgImage:newImage)
        
        return image
    }
}
