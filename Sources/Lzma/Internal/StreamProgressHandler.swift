//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma

typealias CStreamProgress = @convention(c) (
    UnsafePointer<IStreamProgress_>?,
    UInt64,
    UInt64
) -> Void

typealias FinalizeCompressProgress = @convention(c) (UnsafePointer<IStreamProgress>?) -> Void

final class StreamProgressHandler: @unchecked Sendable {
    private let progressFunc: (Int, Int) -> Void

    init(progressFunc: @escaping (Int, Int) -> Void) {
        self.progressFunc = progressFunc
    }

    func progress(_ inSize: UInt64, _ outSize: UInt64) {
        progressFunc(Int(truncatingIfNeeded: inSize),
                     Int(truncatingIfNeeded: outSize))
    }
}

extension StreamProgressHandler {
    var context: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    var finalize: FinalizeCompressProgress {
        return { ptr in
            guard let ptr else {
                return
            }

            Unmanaged<StreamProgressHandler>
                .fromOpaque(ptr.pointee.context)
                .release()
        }
    }

    var progress: CStreamProgress {
        return { ptr, inSize, outSize in
            guard let ptr else {
                return
            }

            let handler = Unmanaged<StreamProgressHandler>.fromOpaque(ptr.pointee.context).takeUnretainedValue()
            handler.progress(inSize, outSize)
        }
    }
}
