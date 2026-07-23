//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import struct Foundation.Data

typealias CReadStream = @convention(c) (
    UnsafePointer<ISeqInStream_>?,
    UnsafeMutableRawPointer?,
    UnsafeMutablePointer<Int>?
) -> Int32

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
        return { ptr in
            guard let ptr else {
                return
            }

            Unmanaged<ReadHandler>
                .fromOpaque(ptr.pointee.context)
                .release()
        }
    }

    var readStream: CReadStream {
        return {
            ptr,
            buff,
            size in
            guard let ptr,
                  let size,
                  let buff
            else {
                return SZ_ERROR_READ
            }

            let handler = Unmanaged<ReadHandler>.fromOpaque(ptr.pointee.context).takeUnretainedValue()

            do {
                guard let data = try handler.read(length: size.pointee) else {
                    size.pointee = 0
                    return SZ_OK
                }

                data.bytes.withUnsafeBytes { buffer in
                    buff.copyMemory(from: buffer.baseAddress!, byteCount: buffer.count)
                    size.pointee = buffer.count
                }

            } catch {
                return SZ_ERROR_READ
            }

            return SZ_OK
        }
    }
}
