//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

public extension XZDecoder {
    func decode(from data: Data, write: @escaping (Data) throws -> Void, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(XZError) {
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

        }, write: write,
        progress: progress)
    }
}

public extension XZDecoder {
    func decode(from data: Data, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(XZError) -> Data {
        var result = Data()
        try decode(from: data, write: { data in
            result.append(data)
        }, progress: progress)
        return result
    }
}
