//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma
import struct Foundation.Data

public struct EncoderConfiguration: Equatable, Sendable {
    public var inputBufferSize: Int
    public var outputBufferSize: Int
    public var preset: UInt32

    public init(inputBufferSize: Int = 8192, outputBufferSize: Int = 8192, preset: UInt32 = 6) {
        self.inputBufferSize = inputBufferSize
        self.outputBufferSize = outputBufferSize
        self.preset = min(max(0, preset), 9)
    }
}

public struct XZEncoder: Sendable {
    public init() {}
}

@available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
public extension XZEncoder {
    func encode(configuration: EncoderConfiguration = .init(),
                read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Void = { _, _ in
                }) throws(XZError)
    {
        let readHandler = ReadHandler(read: read)
        let writeHandler = WriteHandler(write: write)

        let progressHandler = CompressProgressHandler(progressFunc: progress)

        var readStream = ISeqInStream(
            Read: readHandler.readStream,
            Finalize: readHandler.finalize,
            context: readHandler.context
        )
        var writeStream = ISeqOutStream(
            Write: writeHandler.writeStream,
            Finalize: writeHandler.finalize,
            context: writeHandler.context
        )

        var compressProgress = ICompressProgress(
            Progress: progressHandler.compressProgress,
            Finalize: progressHandler.finalize,
            context: progressHandler.context
        )

        let buffer_config = lzma_buffer_config(input_buffer_size: configuration.inputBufferSize, output_buffer_size: configuration.outputBufferSize)

        let config = lzma_compress_config(buffer_config: buffer_config,
                                          preset: configuration.preset)

        let status = lzma_compress_stream(config, &readStream, &writeStream, &compressProgress)

        guard status == STATUS_OK else {
            throw XZError(status)
        }
    }
}
