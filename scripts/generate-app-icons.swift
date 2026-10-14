//
//  generate-app-icons.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//
//  Generates the per-environment app icons from the Prod icon.
//
//  The Prod icon (LogChain/Assets.xcassets/AppIcon.appiconset/AppIcon.png) is the
//  master. Dev, SIT and UAT get a copy of it with a coloured environment banner.
//  If the master doesn't exist yet, a placeholder is drawn and saved as the master.
//
//  Usage (from the repo root):
//      swift scripts/generate-app-icons.swift
//

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let assetsURL = URL(fileURLWithPath: "LogChain/Assets.xcassets")
let masterURL = assetsURL.appendingPathComponent("AppIcon.appiconset/AppIcon.png")

struct Variant {
    let setName: String
    let label: String
    let color: CGColor
}

let variants = [
    Variant(setName: "AppIcon-Dev", label: "DEV", color: CGColor(srgbRed: 0.18, green: 0.65, blue: 0.32, alpha: 1)),
    Variant(setName: "AppIcon-SIT", label: "SIT", color: CGColor(srgbRed: 0.93, green: 0.55, blue: 0.10, alpha: 1)),
    Variant(setName: "AppIcon-UAT", label: "UAT", color: CGColor(srgbRed: 0.55, green: 0.27, blue: 0.85, alpha: 1)),
]

func makeContext() -> CGContext {
    CGContext(
        data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!
}

func loadImage(at url: URL) -> CGImage? {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
}

func writePNG(_ image: CGImage, to url: URL) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw CocoaError(.fileWriteUnknown)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
}

func writeContents(forSet setName: String) throws {
    let json = """
    {
      "images" : [
        {
          "filename" : "AppIcon.png",
          "idiom" : "universal",
          "platform" : "ios",
          "size" : "1024x1024"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }

    """
    let url = assetsURL.appendingPathComponent("\(setName).appiconset/Contents.json")
    try json.write(to: url, atomically: true, encoding: .utf8)
}

/// Placeholder master icon: three linked blocks climbing like a price chart.
func drawPlaceholder() -> CGImage {
    let context = makeContext()
    let s = CGFloat(size)

    let gradient = CGGradient(
        colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
        colors: [
            CGColor(srgbRed: 0.05, green: 0.10, blue: 0.24, alpha: 1),
            CGColor(srgbRed: 0.04, green: 0.42, blue: 0.52, alpha: 1),
        ] as CFArray,
        locations: [0, 1]
    )!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])

    let block: CGFloat = 190
    let centers = [CGPoint(x: 0.27 * s, y: 0.34 * s), CGPoint(x: 0.50 * s, y: 0.50 * s), CGPoint(x: 0.73 * s, y: 0.66 * s)]

    context.setStrokeColor(CGColor(gray: 1, alpha: 0.9))
    context.setLineWidth(34)
    context.setLineCap(.round)
    context.move(to: centers[0])
    centers.dropFirst().forEach { context.addLine(to: $0) }
    context.strokePath()

    context.setFillColor(CGColor(gray: 1, alpha: 1))
    for center in centers {
        let rect = CGRect(x: center.x - block / 2, y: center.y - block / 2, width: block, height: block)
        context.addPath(CGPath(roundedRect: rect, cornerWidth: 44, cornerHeight: 44, transform: nil))
    }
    context.fillPath()

    return context.makeImage()!
}

func drawVariant(of master: CGImage, _ variant: Variant) -> CGImage {
    let context = makeContext()
    let s = CGFloat(size)
    context.draw(master, in: CGRect(x: 0, y: 0, width: s, height: s))

    let bannerHeight = s * 0.24
    context.setFillColor(variant.color)
    context.fill(CGRect(x: 0, y: 0, width: s, height: bannerHeight))

    let font = CTFontCreateWithName("HelveticaNeue-Bold" as CFString, bannerHeight * 0.62, nil)
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor(gray: 1, alpha: 1),
        NSAttributedString.Key(kCTKernAttributeName as String): bannerHeight * 0.06,
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: variant.label, attributes: attributes))
    let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
    context.textPosition = CGPoint(
        x: (s - bounds.width) / 2 - bounds.minX,
        y: (bannerHeight - bounds.height) / 2 - bounds.minY
    )
    CTLineDraw(line, context)

    return context.makeImage()!
}

let master: CGImage
if let existing = loadImage(at: masterURL) {
    master = existing
    print("Using existing master icon at \(masterURL.path)")
} else {
    master = drawPlaceholder()
    try writePNG(master, to: masterURL)
    try writeContents(forSet: "AppIcon")
    print("No master icon found; wrote placeholder to \(masterURL.path)")
}

for variant in variants {
    let url = assetsURL.appendingPathComponent("\(variant.setName).appiconset/AppIcon.png")
    try writePNG(drawVariant(of: master, variant), to: url)
    try writeContents(forSet: variant.setName)
    print("Wrote \(url.path)")
}
