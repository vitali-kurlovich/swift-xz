//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import Foundation

public struct XZEncoder: Sendable {
    /// Compression level (0 <= level <= 9)
    ///
    public var level: Int

    public init(level: Int = -1) {
        self.level = level
    }
}

public extension XZEncoder {
    func encode(read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Bool = { _, _ in
                    false
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

        let res = Encode_XZ_Stream_Level(&readStream, &writeStream, &compressProgress, .init(level))

        guard res == SZ_OK else {
            throw XZError(rawValue: Int32(res)) ?? .unknownError
        }
    }
}
