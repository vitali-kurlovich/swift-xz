//
//  Created by Kurlovich Vitali on 7/26/26.
//

import struct Foundation.Data

protocol DataStreamTransformer {
    func transform(read: @escaping (Int) throws -> Data?,
                   write: @escaping (Data) throws -> Void) throws
}
