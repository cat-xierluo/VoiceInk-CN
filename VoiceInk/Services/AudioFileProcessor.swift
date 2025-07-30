import Foundation
import AVFoundation
import os

class AudioProcessor {
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "AudioProcessor")
    
    struct AudioFormat {
        static let targetSampleRate: Double = 16000.0
        static let targetChannels: UInt32 = 1
        static let targetBitDepth: UInt32 = 16
    }
    
    enum AudioProcessingError: LocalizedError {
        case invalidAudioFile
        case conversionFailed
        case exportFailed
        case unsupportedFormat
        case sampleExtractionFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidAudioFile:
                return "The audio file is invalid or corrupted"
            case .conversionFailed:
                return "Failed to convert the audio format"
            case .exportFailed:
                return "Failed to export the processed audio"
            case .unsupportedFormat:
                return "The audio format is not supported"
            case .sampleExtractionFailed:
                return "Failed to extract audio samples"
            }
        }
    }
    
    /// Process audio file and return samples ready for Whisper
    /// - Parameter url: URL of the input audio file
    /// - Returns: Array of normalized float samples
    func processAudioToSamples(_ url: URL) async throws -> [Float] {
        logger.notice("🎵 Processing audio file to samples: \(url.lastPathComponent)")
        
        // Create AVAudioFile from input
        guard let audioFile = try? AVAudioFile(forReading: url) else {
            logger.error("❌ Failed to create AVAudioFile from input")
            throw AudioProcessingError.invalidAudioFile
        }
        
        // Get format information
        let format = audioFile.processingFormat
        let sampleRate = format.sampleRate
        let channels = format.channelCount
        
        logger.notice("📊 Input format - Sample Rate: \(sampleRate), Channels: \(channels)")
        
        // Create output format (always 16kHz mono float)
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: AudioFormat.targetSampleRate,
            channels: AudioFormat.targetChannels,
            interleaved: false
        )
        
        guard let outputFormat = outputFormat else {
            logger.error("❌ Failed to create output format")
            throw AudioProcessingError.unsupportedFormat
        }
        
        // Read input file into buffer
        let inputBuffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        )
        
        guard let inputBuffer = inputBuffer else {
            logger.error("❌ Failed to create input buffer")
            throw AudioProcessingError.conversionFailed
        }
        
        try audioFile.read(into: inputBuffer)
        
        // If format matches our target, just convert to samples
        if sampleRate == AudioFormat.targetSampleRate && channels == AudioFormat.targetChannels {
            logger.notice("✅ Audio format already matches requirements")
            return convertToWhisperFormat(inputBuffer)
        }
        
        // Create converter for format conversion
        guard let converter = AVAudioConverter(from: format, to: outputFormat) else {
            logger.error("❌ Failed to create audio converter")
            throw AudioProcessingError.conversionFailed
        }
        
        // Create output buffer
        let ratio = AudioFormat.targetSampleRate / sampleRate
        let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: AVAudioFrameCount(Double(inputBuffer.frameLength) * ratio)
        )
        
        guard let outputBuffer = outputBuffer else {
            logger.error("❌ Failed to create output buffer")
            throw AudioProcessingError.conversionFailed
        }
        
        // Perform conversion
        var error: NSError?
        let status = converter.convert(
            to: outputBuffer,
            error: &error,
            withInputFrom: { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return inputBuffer
            }
        )
        
        if let error = error {
            logger.error("❌ Conversion failed: \(error.localizedDescription)")
            throw AudioProcessingError.conversionFailed
        }
        
        if status == .error {
            logger.error("❌ Conversion failed with status: error")
            throw AudioProcessingError.conversionFailed
        }
        
        logger.notice("✅ Successfully converted audio format")
        return convertToWhisperFormat(outputBuffer)
    }
    
    /// Convert audio buffer to Whisper-compatible samples
    private func convertToWhisperFormat(_ buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData else {
            logger.error("❌ No channel data available in buffer")
            return []
        }
        
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        var samples = Array(repeating: Float(0), count: frameLength)
        
        logger.notice("📊 Converting buffer - Channels: \(channelCount), Frames: \(frameLength)")
        
        // If mono, just copy the samples
        if channelCount == 1 {
            samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
            logger.notice("✅ Copied mono samples directly")
        }
        // If stereo or more, average all channels
        else {
            logger.notice("🔄 Converting \(channelCount) channels to mono")
            for frame in 0..<frameLength {
                var sum: Float = 0
                for channel in 0..<channelCount {
                    sum += channelData[channel][frame]
                }
                samples[frame] = sum / Float(channelCount)
            }
        }
        
        // Normalize samples to [-1, 1]
        let maxSample = samples.map(abs).max() ?? 1
        if maxSample > 0 {
            logger.notice("📈 Normalizing samples with max amplitude: \(maxSample)")
            samples = samples.map { $0 / maxSample }
        }
        
        // Log sample statistics
        if let min = samples.min(), let max = samples.max() {
            logger.notice("📊 Final sample range: [\(min), \(max)]")
        }
        
        logger.notice("✅ Successfully converted \(samples.count) samples")
        return samples
    }
    func saveSamplesAsWav(samples: [Float], to url: URL) throws {
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: AudioFormat.targetSampleRate,
            channels: AudioFormat.targetChannels,
            interleaved: true
        )

        guard let outputFormat = outputFormat else {
            throw AudioProcessingError.unsupportedFormat
        }

        let buffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: AVAudioFrameCount(samples.count)
        )
        
        guard let buffer = buffer else {
            throw AudioProcessingError.conversionFailed
        }
        
        // Convert float samples to int16
        let int16Samples = samples.map { max(-1.0, min(1.0, $0)) * Float(Int16.max) }.map { Int16($0) }

        // Copy samples to buffer
        int16Samples.withUnsafeBufferPointer { int16Buffer in
            let int16Pointer = int16Buffer.baseAddress!
            buffer.int16ChannelData![0].update(from: int16Pointer, count: int16Samples.count)
        }
        buffer.frameLength = AVAudioFrameCount(samples.count)

        // Create audio file
        let audioFile = try AVAudioFile(
            forWriting: url,
            settings: outputFormat.settings,
            commonFormat: .pcmFormatInt16,
            interleaved: true
        )

        try audioFile.write(from: buffer)
        logger.notice("✅ Successfully saved processed audio to \(url.lastPathComponent)")
    }
} 

