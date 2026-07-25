//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data

@available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
public extension XZDecoder {
    func decode(configuration: DecoderConfiguration = .init(),
                from data: Data,
                write: @escaping (Data) throws -> Void,
                progress: @escaping (Int, Int) -> Void = { _, _ in }) throws(XZError)
    {
        var configuration = configuration
        configuration.inputBufferSize = min(
            configuration.inputBufferSize,
            data.count
        )

        var position = data.startIndex
        let size = data.count

        try decode(configuration: configuration,
                   read: { length in
                       let rangeLength = Swift.min(length, size - position)

                       if rangeLength == 0 {
                           return nil
                       }

                       let range = position ..< position + rangeLength
                       position += rangeLength

                       return data[range]

                   }, write: write,
                   progress: progress)
    }
}

@available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
public extension XZDecoder {
    func decode(configuration: DecoderConfiguration = .init(),
                from data: Data, progress: @escaping (Int, Int) -> Void = { _, _ in }) throws(XZError) -> Data
    {
        var configuration = configuration
        configuration.inputBufferSize = min(
            configuration.inputBufferSize,
            data.count
        )

        var result = Data()
        try decode(configuration: configuration,
                   from: data, write: { data in
                       result.append(data)
                   }, progress: progress)
        return result
    }
}
