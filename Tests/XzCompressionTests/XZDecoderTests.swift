import Foundation
import Testing
import XzCompression

struct XZDecoderTests {
    @Test
    func decode() throws {
        let decoder = XZDecoder()

        let data = TestData.compressed

        let result = try data.decode(with: decoder)

        #expect(TestData.expected == result)
    }
}
