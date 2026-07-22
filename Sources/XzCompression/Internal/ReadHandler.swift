//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import Foundation

typealias ReadCallback = @convention(c) (
    UnsafePointer<ISeqInStream_>?,
    UnsafeMutableRawPointer?,
    UnsafeMutablePointer<Int>?
) -> Int32

final class ReadHandler: @unchecked Sendable {
    let readFunc: (Int) throws -> Data?

    init(readFunc: @escaping (Int) throws -> Data?) {
        self.readFunc = readFunc
    }

    func read(length: Int) throws -> Data? {
        try readFunc(length)
    }
}
