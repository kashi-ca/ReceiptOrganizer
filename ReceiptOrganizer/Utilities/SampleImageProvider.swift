import UIKit

enum SampleImageProvider {
    static func sampleReceiptImage() -> UIImage {
        if let asset = UIImage(named: "SampleReceipt") {
            return asset
        }
        return generateTextImage(lines: defaultLines)
    }

    private static let defaultLines: [String] = [
        "Coffee Corner",
        "Latte            $4.00",
        "Muffin           $2.50",
        "Tax              $0.52",
        "Total            $7.02",
        "Thank you!"
    ]

    private static func generateTextImage(lines: [String]) -> UIImage {
        let width: CGFloat = 1024
        let margin: CGFloat = 40
        let lineHeight: CGFloat = 48
        let height = margin * 2 + CGFloat(lines.count) * lineHeight

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 28, weight: .regular),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]

            for (idx, line) in lines.enumerated() {
                let y = margin + CGFloat(idx) * lineHeight
                let rect = CGRect(x: margin, y: y, width: width - margin * 2, height: lineHeight)
                (line as NSString).draw(in: rect, withAttributes: attrs)
            }

            UIColor(white: 0.9, alpha: 1).setFill()
            ctx.fill(CGRect(x: margin, y: margin + lineHeight - 8, width: width - margin * 2, height: 1))
        }
    }
}

