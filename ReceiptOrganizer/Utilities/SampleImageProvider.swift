import CoreGraphics
import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif


/// Utilities for supplying a sample receipt image during local testing.
enum SampleImageProvider {
    static let imageNames = ["receipt-ocr-original", "sample2", "sample3", "sample4"]
    static var counter = 0
    /// Returns a generated sample receipt-like image as `CGImage`.
    /// Generated via Core Graphics to keep dependencies minimal.
    static func sampleReceiptImage() -> CGImage? {
        #if os(iOS)
        let index = counter % 4
        counter += 1
        return UIImage(named: imageNames[index])!.cgImage!
        #else
        if let image = NSImage(named: "receipt-ocr-original") {
            return image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        }
        #endif
        return nil
    }
}
