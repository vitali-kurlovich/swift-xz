//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaDecoder {
    func decode(from data: Data,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Void = { _, _ in },
                cancel: @escaping () -> Bool = { false }) throws
    {
        var position = data.startIndex
        let size = data.count

        try decode(read: { length in
                       let rangeLength = Swift.min(length, size - position)

                       if rangeLength == 0 {
                           return nil
                       }

                       let range = position ..< position + rangeLength
                       position += rangeLength

                       return data[range]

                   },
                   write: write,
                   progress: progress,
                   cancel: cancel)
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaDecoder {
    func decode(from data: Data,
                progress: @escaping (Int, Int) -> Void = { _, _ in },
                cancel: @escaping () -> Bool = { false }) throws -> Data
    {
        var result = Data()
        try decode(from: data,
                   write: { result.append($0) },
                   progress: progress,
                   cancel: cancel)
        return result
    }

    func decode(read: @escaping (Int) throws -> Data?,
                progress: @escaping (Int, Int) -> Void = { _, _ in },
                cancel: @escaping () -> Bool = { false }) throws -> Data
    {
        var result = Data()
        try decode(read: read,
                   write: { result.append($0) },
                   progress: progress,
                   cancel: cancel)
        return result
    }
}
