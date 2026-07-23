//
//  Created by Kurlovich Vitali on 7/23/26.
//

import CLzma

typealias CompressProgress = @convention(c) (
    UnsafePointer<ICompressProgress_>?,
    UInt64,
    UInt64
) -> Int32

typealias FinalizeCompressProgress = @convention(c) (UnsafePointer<ICompressProgress>?) -> Void

final class CompressProgressHandler: @unchecked Sendable {
    private let progressFunc: (Int, Int) -> Bool

    init(progressFunc: @escaping (Int, Int) -> Bool) {
        self.progressFunc = progressFunc
    }

    func progress(_ inSize: UInt64, _ outSize: UInt64) -> Bool {
        progressFunc(Int(truncatingIfNeeded: inSize),
                     Int(truncatingIfNeeded: outSize))
    }
}

extension CompressProgressHandler {
    var context: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }

    var finalize: FinalizeCompressProgress {
        return { ptr in
            guard let ptr else {
                return
            }

            Unmanaged<CompressProgressHandler>
                .fromOpaque(ptr.pointee.context)
                .release()
        }
    }

    var compressProgress: CompressProgress {
        return { ptr, inSize, outSize in
            guard let ptr else {
                return .init(SZ_ERROR_PROGRESS)
            }

            let handler = Unmanaged<CompressProgressHandler>.fromOpaque(ptr.pointee.context).takeUnretainedValue()

            if handler.progress(inSize, outSize) {
                return .init(SZ_ERROR_PROGRESS)
            }
            return .init(SZ_OK)
        }
    }
}
