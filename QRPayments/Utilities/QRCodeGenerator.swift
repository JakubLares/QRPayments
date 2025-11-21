//
//  QRCodeGenerator.swift
//  QRPayments
//
//  Generates QR code images from strings
//
//  Created on 2025-11-20
//

import UIKit
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {

    /// Generates a QR code image from a string
    /// - Parameters:
    ///   - text: The text to encode in the QR code
    ///   - size: The size of the QR code image (default: 512x512)
    /// - Returns: UIImage of the QR code, or nil if generation fails
    static func generate(from text: String, size: CGFloat = 512) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(text.utf8)
        filter.correctionLevel = "M" // Medium error correction (15%)

        guard let outputImage = filter.outputImage else {
            return nil
        }

        // Scale up the QR code to the desired size
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
