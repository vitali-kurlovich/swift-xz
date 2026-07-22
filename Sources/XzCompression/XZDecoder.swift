//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import Foundation

public struct XZDecoder: Sendable {
    public init() {}
}

public extension XZDecoder {
    func decode(readFunc: @escaping (Int) throws -> Data?,
                writeFunc: @escaping (Data) throws -> Void) throws(XZError)
    {
        let readHandler = ReadHandler(readFunc: readFunc)
        let writeHandler = WriteHandler(writeFunc: writeFunc)

        let readCallback: ReadCallback = { ptr,
            buff,
            size in
            guard let ptr, let size, let buff else {
                return SZ_ERROR_READ
            }

            let handler = Unmanaged<ReadHandler>.fromOpaque(ptr.pointee.context).takeRetainedValue()

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

        let writeCallback: WriteCallback = { ptr, buff, size in
            guard let ptr, let buff else {
                return 0
            }

            do {
                let handler = Unmanaged<WriteHandler>.fromOpaque(ptr.pointee.context).takeRetainedValue()

                let rawPointer = UnsafeRawPointer(buff)
                let data = Data(bytes: rawPointer, count: size)
                try handler.write(data)
                return size
            } catch {
                return Int(0)
            }
        }

        let readContext = UnsafeMutableRawPointer(Unmanaged.passRetained(readHandler).toOpaque())
        let writeContext = UnsafeMutableRawPointer(Unmanaged.passRetained(writeHandler).toOpaque())

        var readStream = ISeqInStream(Read: readCallback, context: readContext)
        var writeStream = ISeqOutStream(Write: writeCallback, context: writeContext)

        let result = Decode_XZ_Stream(&readStream, &writeStream)

        guard result == SZ_OK else {
            throw XZError(rawValue: Int32(result)) ?? .unknownError
        }
    }
}
