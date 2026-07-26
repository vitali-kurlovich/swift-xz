//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma
import struct Foundation.Data

typealias CReadStream = @convention(c) (
    UnsafePointer<ISeqInStream_>?,
    UnsafeMutableRawPointer?,
    UnsafeMutablePointer<Int>?,
    UnsafeMutablePointer<lzma_io_status>?,
) -> Void

typealias FinalizeReadStream = @convention(c) (UnsafePointer<ISeqInStream_>?) -> Void

final class ReadHandler: @unchecked Sendable {
    private let readFunc: (Int) throws -> Data?

    init(read: @escaping (Int) throws -> Data?) {
        readFunc = read
    }

    func read(length: Int) throws -> Data? {
        try readFunc(length)
    }
}

extension ReadHandler {
    var context: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    var finalize: FinalizeReadStream {
        { ptr in
            guard let ptr else {
                return
            }

            Unmanaged<ReadHandler>
                .fromOpaque(ptr.pointee.context)
                .release()
        }
    }

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    var readStream: CReadStream {
        { ptr, buff, size, status in
            guard let ptr, let size, let buff, let status else {
                status?.pointee = STATUS_IO_READ_ERROR
                return
            }

            let handler = Unmanaged<ReadHandler>.fromOpaque(ptr.pointee.context).takeUnretainedValue()

            do {
                guard let data = try handler.read(length: .init(size.pointee)) else {
                    size.pointee = 0
                    return
                }

                data.bytes.withUnsafeBytes { buffer in
                    buff.copyMemory(from: buffer.baseAddress!, byteCount: buffer.count)
                    size.pointee = .init(buffer.count)
                }

            } catch {
                status.pointee = STATUS_IO_READ_ERROR
            }
        }
    }
}
