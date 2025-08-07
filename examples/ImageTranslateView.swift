//
//  ImageTranslateView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//


import PhotosUI
import SwiftUI
import Vision

#if os(macOS)
struct TextBlock: Identifiable {
    let id = UUID()
    let original: String
    let translated: String
    let boundingBox: CGRect  // in normalized coordinates (0~1)
}

struct ImageTranslateView: View {
    @State private var image: NSImage?
    @State private var textBlocks: [TextBlock] = []

    var body: some View {
        VStack {
            if let img = NSImage(named: "moe-001189") {
                TranslatedImageView(image: img, textBlocks: textBlocks)
                    .onAppear {
                        recognizeTextBlocks(from: img) { blocks in
                            self.textBlocks = blocks
                        }
                    }
            }
        }
    }
}

struct TranslatedImageView: View {
    let image: NSImage
    let textBlocks: [TextBlock]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)

                ForEach(textBlocks) { block in
                    let imgSize = geo.size
                    let rect = convertToImageCoordinates(
                        box: block.boundingBox,
                        imageSize: imgSize
                    )

                    Text(block.translated)
                        .foregroundColor(.red)
                        .frame(
                            width: rect.width,
                            height: rect.height
                        )
                        .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }

    func convertToImageCoordinates(box: CGRect, imageSize: CGSize) -> CGRect {
        // Vision 的坐标是以左下角为原点，需要转换成 SwiftUI 以左上角为原点的坐标系
        let x = box.minX * imageSize.width
        let y = (1 - box.maxY) * imageSize.height
        let width = box.width * imageSize.width
        let height = box.height * imageSize.height

        return CGRect(x: x, y: y, width: width, height: height)
    }
}

func recognizeTextBlocks(
    from image: NSImage,
    completion: @escaping ([TextBlock]) -> Void
) {
    guard
        let cgImage = image.cgImage(
            forProposedRect: .none,
            context: .none,
            hints: .none
        )
    else { return }

    let request = VNRecognizeTextRequest { request, error in
        guard let results = request.results as? [VNRecognizedTextObservation]
        else { return }

        var blocks: [TextBlock] = []

        for observation in results {
            guard let candidate = observation.topCandidates(1).first else {
                continue
            }
            let originalText = candidate.string
            let boundingBox = observation.boundingBox

            // 翻译可以使用同步/异步方式（这里简化为原文）
            let translatedText = "译文"  // 你可以换成异步翻译
            let block = TextBlock(
                original: originalText,
                translated: translatedText,
                boundingBox: boundingBox
            )
            blocks.append(block)
        }

        DispatchQueue.main.async {
            completion(blocks)
        }
    }

    request.recognitionLanguages = ["zh-Hans"]
    request.recognitionLevel = .accurate

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try? handler.perform([request])
}

#Preview {
    ImageTranslateView()
}
#endif
