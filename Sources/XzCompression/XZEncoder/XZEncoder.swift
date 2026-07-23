//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import Foundation

public struct XZEncoder: Sendable {
    public init() {}
}

public extension XZEncoder {
    func encode(read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void) throws(XZError)
    {
        let readHandler = ReadHandler(read: read)
        let writeHandler = WriteHandler(write: write)

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

        let result = Encode_XZ_Stream(&readStream, &writeStream)

        guard result == SZ_OK else {
            throw XZError(rawValue: Int32(result)) ?? .unknownError
        }
    }
}
