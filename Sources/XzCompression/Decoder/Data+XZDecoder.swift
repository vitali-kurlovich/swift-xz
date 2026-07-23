//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

public extension Data {
    func decode(with decoder: XZDecoder) throws(XZError) -> Data {
        var position = startIndex
        let size = count

        var result = Data()

        try decoder.decode { length in
            let rangeLength = Swift.min(length, size - position)

            if rangeLength == 0 {
                return nil
            }

            let range = position ..< position + rangeLength
            position += rangeLength

            return self[range]

        } write: { data in
            result.append(data)
        }

        return result
    }
}
