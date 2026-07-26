//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaEncoder {
    func encode(from data: Data, write: @escaping (Data) throws -> Void) throws {
        try _encoder.transform(from: data, write: write)
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaEncoder {
    func encode(from data: Data) throws -> Data {
        try _encoder.transform(from: data)
    }

    func encode(read: @escaping (Int) throws -> Data?) throws -> Data {
        try _encoder.transform(read: read)
    }
}
