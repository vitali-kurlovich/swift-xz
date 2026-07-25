//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

#if canImport(Compression)
    import Compression
#else
    import clzma
#endif

public struct LzmaEncoder: Sendable {
    public init() {}
}

public extension LzmaEncoder {
    struct Configuration: Equatable, Sendable {
        public var inputBufferSize: Int
        public var outputBufferSize: Int
        public var preset: UInt32

        public init(inputBufferSize: Int = 8192, outputBufferSize: Int = 8192, preset: UInt32 = 6) {
            self.inputBufferSize = inputBufferSize
            self.outputBufferSize = outputBufferSize
            self.preset = min(max(0, preset), 9)
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension LzmaEncoder {
    func encode(configuration: Configuration = .init(),
                read: @escaping (Int) throws -> Data?,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Void = { _, _ in },
                cancel: @escaping () -> Bool = { false }) throws
    {
        #if canImport(Compression)
            var inSize = 0
            var outSize = 0

            do {
                let inputFilter = try InputFilter(.compress,
                                                  using: .lzma,
                                                  bufferCapacity: configuration.inputBufferSize,
                                                  readingFrom: {
                                                      if cancel() {
                                                          throw LzmaError.canceled
                                                      }

                                                      do {
                                                          let data = try read($0)
                                                          inSize += data?.count ?? 0
                                                          return data
                                                      } catch {
                                                          throw LzmaError.readError
                                                      }
                                                  })

                while let page = try inputFilter.readData(ofLength: configuration.outputBufferSize) {
                    if cancel() {
                        throw LzmaError.canceled
                    }

                    outSize += page.count

                    do {
                        try write(page)
                    } catch {
                        throw LzmaError.writeError
                    }

                    progress(inSize, outSize)
                }
            } catch let error as LzmaError {
                throw error
            } catch {
                throw LzmaError.dataError
            }

        #else

            let readHandler = ReadHandler(read: read)
            let writeHandler = WriteHandler(write: write)

            let progressHandler = StreamProgressHandler(progressFunc: progress)
            let cancelHandler = StreamCancelationHandler(cancel: cancel)

            var readStream = ISeqInStream(
                Read: readHandler.readStream,
                Finalize: readHandler.finalize,
                context: readHandler.context
            )
            var writeStream = ISeqOutStream(
                Write: writeHandler.writeStream,
                Finalize: writeHandler.finalize,
                context: writeHandler.context
            )

            var streamProgress = IStreamProgress(
                Progress: progressHandler.progress,
                Finalize: progressHandler.finalize,
                context: progressHandler.context
            )

            var caceletion = IStreamCancelation(
                Cancelation: cancelHandler.cancelation,
                Finalize: cancelHandler.finalize,
                context: cancelHandler.context
            )

            let buffer_config = lzma_buffer_config(input_buffer_size: configuration.inputBufferSize, output_buffer_size: configuration.outputBufferSize)

            let config = lzma_compress_config(buffer_config: buffer_config,
                                              preset: configuration.preset)

            let status = lzma_compress_stream(config, &readStream, &writeStream, &streamProgress, &caceletion)

            guard status == STATUS_OK else {
                throw LzmaError(status)
            }
        #endif
    }
}
