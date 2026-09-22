//
//  Created by Kurlovich Vitali on 7/26/26.
//

import struct Foundation.Data

extension DataStreamTransformer {
    func transform(from data: Data,
                   write: @escaping (Data) throws -> Void) throws
    {
        var position = data.startIndex
        let size = data.count

        try transform(read: { length in
                          let rangeLength = Swift.min(length, size - position)

                          if rangeLength == 0 {
                              return nil
                          }

                          let range = position ..< position + rangeLength
                          position += rangeLength

                          return data[range]

                      },
                      write: write)
    }
}

extension DataStreamTransformer {
    func transform(from data: Data) throws -> Data {
        var result = Data()
        try transform(from: data, write: { result.append($0) })
        return result
    }

    func transform(read: @escaping (Int) throws -> Data?) throws -> Data {
        var result = Data()
        try transform(read: read, write: { result.append($0) })
        return result
    }
}
