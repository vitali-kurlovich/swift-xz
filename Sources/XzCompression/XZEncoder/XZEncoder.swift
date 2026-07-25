//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma
import struct Foundation.Data

public struct XZEncoder: Sendable {
    public var level: UInt
    public init(level: UInt = 6) {
        self.level = min(max(0, level), 9)
    }
}

@available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
public extension XZEncoder {
    func encode(read: @escaping (Int) throws -> Data?,
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

        let status = lzma_compress_stream(&readStream, &writeStream, &compressProgress, .init(level))

        guard status == STATUS_OK else {
            throw XZError(status)
        }
    }
}
