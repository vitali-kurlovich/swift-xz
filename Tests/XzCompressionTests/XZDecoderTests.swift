import Foundation
import Testing
@testable import XzCompression

struct XZDecoderTests {
    @Test
    func decode() throws {
        let decoder = XZDecoder()

        let data = TestData.compressed

        var position = data.startIndex
        let size = data.count

        var result = Data()
        do {
            try decoder.decode { length in
                let rangeLength = Swift.min(length, size - position)

                if rangeLength == 0 {
                    return nil
                }

                let range = position ..< position + rangeLength
                position += rangeLength

                return data[range]

            } writeFunc: { data in
                result.append(data)
            }

        } catch {
            #expect(error == .crcError)
        }

        #expect(TestData.expected == result)
    }
}
