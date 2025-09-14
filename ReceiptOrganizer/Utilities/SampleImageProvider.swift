import CoreGraphics
import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif


/// Utilities for supplying a sample receipt image during local testing.
enum SampleImageProvider {
    /// Returns a generated sample receipt-like image as `CGImage`.
    /// Generated via Core Graphics to keep dependencies minimal.
    static func sampleReceiptImage() -> CGImage? {
        #if os(iOS)
        return UIImage(named: "receipt-ocr-original")!.cgImage!
        #else
        if let image = NSImage(named: "receipt-ocr-original") {
            return image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        }
        #endif
        return nil
    }
}
