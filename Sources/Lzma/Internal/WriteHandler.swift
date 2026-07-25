
//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma
import struct Foundation.Data

typealias WriteStream = @convention(c) (UnsafePointer<ISeqOutStream_>?, UnsafeRawPointer?, Int, UnsafeMutablePointer<lzma_io_status>?) -> Int

typealias FinalizeWriteStream = @convention(c) (UnsafePointer<ISeqOutStream_>?) -> Void

final class WriteHandler: @unchecked Sendable {
    private let writeFunc: (Data) throws -> Void

    init(write: @escaping (Data) throws -> Void) {
        writeFunc = write
    }

    func write(_ data: Data) throws {
        try writeFunc(data)
    }
}

extension WriteHandler {
    var context: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    var finalize: FinalizeWriteStream {
        return { ptr in
            guard let ptr else {
                return
            }

            Unmanaged<WriteHandler>
                .fromOpaque(ptr.pointee.context)
                .release()
        }
    }

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    var writeStream: WriteStream {
        return { ptr, buff, size, status in
            guard let ptr, let buff, let status else {
                status?.pointee = STATUS_IO_WRITE_ERROR
                return 0
            }

            do {
                let handler = Unmanaged<WriteHandler>.fromOpaque(ptr.pointee.context).takeUnretainedValue()

                let rawPointer = UnsafeRawPointer(buff)
                let data = Data(bytes: rawPointer, count: size)
                try handler.write(data)

                return size
            } catch {
                status.pointee = STATUS_IO_WRITE_ERROR
            }

            return 0
        }
    }
}
