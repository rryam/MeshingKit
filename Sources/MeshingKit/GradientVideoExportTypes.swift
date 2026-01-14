//
//  GradientVideoExportTypes.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 1/15/26.
//

import SwiftUI

#if canImport(AVFoundation) && canImport(CoreImage) && (canImport(UIKit) || canImport(AppKit))
import AVFoundation
import CoreImage
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension MeshingKit {
    final class VideoWriterState {
        var frameIndex: Int = 0
        var isFinished: Bool = false
    }

    /// Thread-safe holder for the continuation to enable cancellation handling.
    final class ContinuationHolder: @unchecked Sendable {
        private let lock = NSLock()
        private var continuation: CheckedContinuation<Void, Error>?
        private var hasResumed = false

        func set(_ continuation: CheckedContinuation<Void, Error>) {
            lock.lock()
            defer { lock.unlock() }
            self.continuation = continuation
        }

        func resumeWithCancellation() {
            lock.lock()
            defer { lock.unlock() }
            guard !hasResumed, let cont = continuation else { return }
            hasResumed = true
            continuation = nil
            cont.resume(throwing: CancellationError())
        }

        func markResumed() {
            lock.lock()
            defer { lock.unlock() }
            hasResumed = true
            continuation = nil
        }
    }

    struct AssetWriterConfig {
        let assetWriter: AVAssetWriter
        let writerInput: AVAssetWriterInput
        let adaptor: AVAssetWriterInputPixelBufferAdaptor
    }

    struct VideoExportConfig: Sendable {
        let outputURL: URL
        let viewSize: CGSize
        let outputSize: CGSize
        let frameRate: Int32
        let fileType: AVFileType
        let duration: TimeInterval
        let snapshot: VideoExportSnapshot
    }

    struct FrameLoopConfig: Sendable {
        let totalFrames: Int
        let timePerFrame: Double
        let viewSize: CGSize
        let outputSize: CGSize
        let snapshot: VideoExportSnapshot
    }

    static func makeLoopConfig(config: VideoExportConfig) -> FrameLoopConfig {
        let totalFrames = max(
            1,
            Int((config.duration * Double(config.frameRate)).rounded(.toNearestOrAwayFromZero))
        )
        let timePerFrame = 1.0 / Double(config.frameRate)

        return FrameLoopConfig(
            totalFrames: totalFrames,
            timePerFrame: timePerFrame,
            viewSize: config.viewSize,
            outputSize: config.outputSize,
            snapshot: config.snapshot
        )
    }

    static func makeLoopDriver(config: VideoExportConfig) throws -> FrameLoopDriver {
        let assetConfig = try configureAssetWriter(
            outputURL: config.outputURL,
            fileType: config.fileType,
            videoSize: config.outputSize,
            frameRate: config.frameRate
        )

        let frameDuration = CMTimeMake(value: 1, timescale: config.frameRate)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let state = VideoWriterState()

        return FrameLoopDriver(
            assetConfig: assetConfig,
            context: context,
            frameDuration: frameDuration,
            state: state
        )
    }
}
#endif
