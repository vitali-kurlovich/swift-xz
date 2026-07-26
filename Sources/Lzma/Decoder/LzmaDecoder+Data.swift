//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaDecoder {
    func decode(from data: Data,
                write: @escaping (Data) throws -> Void) throws
    {
        try _decoder.transform(from: data, write: write)
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaDecoder {
    func decode(from data: Data) throws -> Data {
        try _decoder.transform(from: data)
    }

    func decode(read: @escaping (Int) throws -> Data?) throws -> Data {
        try _decoder.transform(read: read)
    }
}
