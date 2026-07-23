//
//  Created by Kurlovich Vitali on 7/23/26.
//

import Foundation
import Testing
import XzCompression

struct XZEncoderTests {
    @Test
    func encode() throws {
        let encoder = XZEncoder()

        let data = TestData.expected

        let result = try encoder.encode(from: data)

        #expect(data != result)

        let decoder = XZDecoder()
        #expect(try decoder.decode(from: result) == data)
    }
}
