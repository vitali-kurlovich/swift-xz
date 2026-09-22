//
//  Created by Kurlovich Vitali on 7/25/26.
//

#if os(Linux)
    import clzma

    typealias CStreamCancelation = @convention(c) (
        UnsafePointer<IStreamCancelation_>?,
        UnsafeMutablePointer<Bool>?,
    ) -> Void
    typealias FinalizeCancelation = @convention(c) (UnsafePointer<IStreamCancelation_>?) -> Void

    final class StreamCancelationHandler: @unchecked Sendable {
        private let cancelFunc: () -> Bool

        init(cancel: @escaping () -> Bool) {
            cancelFunc = cancel
        }

        var isCancelled: Bool {
            cancelFunc()
        }
    }

    extension StreamCancelationHandler {
        var context: UnsafeMutableRawPointer {
            UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        }

        var finalize: FinalizeCancelation {
            { ptr in
                guard let ptr else {
                    return
                }

                Unmanaged<StreamCancelationHandler>
                    .fromOpaque(ptr.pointee.context)
                    .release()
            }
        }

        var cancelation: CStreamCancelation {
            { ptr, cancel in
                guard let ptr, let cancel else {
                    return
                }
                let handler = Unmanaged<StreamCancelationHandler>.fromOpaque(ptr.pointee.context).takeUnretainedValue()
                cancel.pointee = handler.isCancelled
            }
        }
    }

#endif
