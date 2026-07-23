//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

public extension XZEncoder {
    func encode(from data: Data, write: @escaping (Data) throws -> Void) throws(XZError) {
        var position = data.startIndex
        let size = data.count

        try encode(read: { length in
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

public extension XZEncoder {
    func encode(from data: Data) throws(XZError) -> Data {
        var result = Data()
        try encode(from: data) { data in
            result.append(data)
        }
        return result
    }
}
