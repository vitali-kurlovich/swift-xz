//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

public extension XZDecoder {
    func decode(from data: Data, write: @escaping (Data) throws -> Void) throws(XZError) {
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

        }, write: write)
    }
}

public extension XZDecoder {
    func decode(from data: Data) throws(XZError) -> Data {
        var result = Data()
        try decode(from: data) { data in
            result.append(data)
        }
        return result
    }
}
