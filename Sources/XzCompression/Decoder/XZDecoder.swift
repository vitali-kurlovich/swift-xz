//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma
import struct Foundation.Data

public struct XZDecoder: Sendable {
    public init() {}
}

public extension XZDecoder {
    func decode(read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Void = { _, _ in }) throws(XZError)
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

        let status = lzma_decompress_stream(&readStream, &writeStream, &compressProgress)

        guard status == STATUS_OK else {
            throw XZError(status)
        }
    }
}
