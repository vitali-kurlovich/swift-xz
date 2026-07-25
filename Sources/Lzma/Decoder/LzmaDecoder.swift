//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma
import struct Foundation.Data

public struct LzmaDecoder: Sendable {
    public init() {}
}

public extension LzmaDecoder {
    struct Configuration: Equatable, Sendable {
        public var inputBufferSize: Int
        public var outputBufferSize: Int

        public init(inputBufferSize: Int = 8192, outputBufferSize: Int = 8192) {
            self.inputBufferSize = inputBufferSize
            self.outputBufferSize = outputBufferSize
        }
    }
}

@available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
public extension LzmaDecoder {
    func decode(configuration: Configuration = .init(),
                read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Void = { _, _ in }) throws(LzmaError)
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

        let config = lzma_decompress_config(
            input_buffer_size: .init(configuration.inputBufferSize),
            output_buffer_size: .init(configuration.outputBufferSize)
        )

        let status = lzma_decompress_stream(config, &readStream, &writeStream, &compressProgress)

        guard status == STATUS_OK else {
            throw LzmaError(status)
        }
    }
}
