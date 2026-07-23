//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import struct Foundation.Data

public struct XZDecoder: Sendable {
    public init() {}
}

public extension XZDecoder {
    func decode(read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(XZError)
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

        let result = Decode_XZ_Stream(&readStream, &writeStream, &compressProgress)

        guard result == SZ_OK else {
            throw XZError(rawValue: Int32(result)) ?? .unknownError
        }
    }
}
