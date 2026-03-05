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
        private var completion: Result<Void, Error>?

        func set(_ continuation: CheckedContinuation<Void, Error>) {
            var pendingCompletion: Result<Void, Error>?
            lock.lock()
            if let completion {
                pendingCompletion = completion
            } else {
                self.continuation = continuation
            }
            lock.unlock()

            guard let pendingCompletion else { return }
            switch pendingCompletion {
            case .success:
                continuation.resume()
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }

        func resumeWithCancellation() {
            resume(throwing: CancellationError())
        }

        func resume(throwing error: Error) {
            complete(with: .failure(error))
        }

        func resume() {
            complete(with: .success(()))
        }

        private func complete(with result: Result<Void, Error>) {
            var continuationToResume: CheckedContinuation<Void, Error>?
            lock.lock()
            guard completion == nil else {
                lock.unlock()
                return
            }
            completion = result
            continuationToResume = continuation
            continuation = nil
            lock.unlock()

            guard let continuationToResume else { return }
            switch result {
            case .success:
                continuationToResume.resume()
            case .failure(let error):
                continuationToResume.resume(throwing: error)
            }
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
