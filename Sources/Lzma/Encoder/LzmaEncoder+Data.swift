//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

public extension LzmaEncoder {
    func encode(from data: Data, write: @escaping (Data) throws -> Void) throws {
        try _encoder.transform(from: data, write: write)
    }
}

public extension LzmaEncoder {
    func encode(from data: Data) throws -> Data {
        try _encoder.transform(from: data)
    }

    func encode(read: @escaping (Int) throws -> Data?) throws -> Data {
        try _encoder.transform(read: read)
    }
}
