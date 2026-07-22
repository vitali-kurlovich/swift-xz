
//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma
import Foundation

typealias WriteCallback = @convention(c) (UnsafePointer<ISeqOutStream_>?, UnsafeRawPointer?, Int) -> Int

final class WriteHandler: @unchecked Sendable {
    let writeFunc: (Data) throws -> Void

    init(writeFunc: @escaping (Data) throws -> Void) {
        self.writeFunc = writeFunc
    }

    func write(_ data: Data) throws {
        try writeFunc(data)
    }
}
