//
//  GradientVideoExportTypes.swift
//  MeshingKit
//
//  Created by Rudrank Riyam on 1/15/26.
//

import SwiftUI
import simd

#if canImport(AVFoundation) && canImport(CoreImage) && (canImport(UIKit) || canImport(AppKit))
import AVFoundation
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
        let precomputedAnimatedPositions: [[SIMD2<Float>]]?
        let animationPattern: AnimationPattern?

        func points(forFrame frameIndex: Int) -> [SIMD2<Float>] {
            if let precomputedAnimatedPositions {
                return precomputedAnimatedPositions[frameIndex]
            }
            let phase = Double(frameIndex) * timePerFrame
            if let pattern = animationPattern {
                let animated = pattern.apply(to: snapshot.positions, at: phase)
                return animated.map { simd_clamp($0, .zero, SIMD2<Float>(repeating: 1)) }
            }
            return MeshingKit.animatedPositions(
                for: phase,
                positions: snapshot.positions,
                animate: snapshot.shouldAnimate
            )
        }
    }

    static func makeLoopConfig(config: VideoExportConfig) -> FrameLoopConfig {
        let totalFrames = max(
            1,
            Int((config.duration * Double(config.frameRate)).rounded(.toNearestOrAwayFromZero))
        )
        let timePerFrame = 1.0 / Double(config.frameRate)
        let shouldPrecompute = config.snapshot.shouldAnimate
            && totalFrames <= maxPrecomputedAnimationFrames
        let pattern = config.snapshot.shouldAnimate ? config.snapshot.animationPattern : nil

        let precomputedAnimatedPositions: [[SIMD2<Float>]]? = if shouldPrecompute {
            (0..<totalFrames).map { frameIndex in
                let phase = Double(frameIndex) * timePerFrame
                if let pattern {
                    let animated = pattern.apply(to: config.snapshot.positions, at: phase)
                    return animated.map { simd_clamp($0, .zero, SIMD2<Float>(repeating: 1)) }
                }
                return MeshingKit.animatedPositions(
                    for: phase,
                    positions: config.snapshot.positions,
                    animate: true
                )
            }
        } else {
            nil
        }

        return FrameLoopConfig(
            totalFrames: totalFrames,
            timePerFrame: timePerFrame,
            viewSize: config.viewSize,
            outputSize: config.outputSize,
            snapshot: config.snapshot,
            precomputedAnimatedPositions: precomputedAnimatedPositions,
            animationPattern: pattern
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
        let state = VideoWriterState()

        return FrameLoopDriver(
            assetConfig: assetConfig,
            frameDuration: frameDuration,
            state: state
        )
    }

    private static let maxPrecomputedAnimationFrames = 12_000
}
#endif
