//
//  Created by Kurlovich Vitali on 7/23/26.
//

import Foundation
import Testing
import XzCompression

@Suite(.disabled())
struct XZEncoderTests {
    @Test("XZEncoder encode data")
    func encode() throws {
        let encoder = XZEncoder()

        let data = TestData.expected

        let result = try encoder.encode(from: data)

        #expect(data != result)

        let decoder = XZDecoder()
        #expect(try decoder.decode(from: result) == data)
    }

    @Test("XZEncoder Error handling")
    func error() throws {
        let encoder = XZEncoder()

        #expect(throws: XZError.writeError) {
            try encoder.encode(from: TestData.expected) { _ in
                throw IOError.writeError
            }
        }
    }

    @Test("XZEncoder Encode to file")
    func fileEncode() throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".txt")
        let compessedURL = tempDir.appendingPathComponent(UUID().uuidString + ".moc")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: compessedURL)
        }

        // 4. Write mock data to the temporary file
        try TestData.expected.write(to: fileURL, options: [.atomic])

        let encoder = XZEncoder()

        try encoder.encode(from: fileURL, writeToUrl: compessedURL)

        let decoder = XZDecoder()

        #expect(try decoder.decode(from: compessedURL) == TestData.expected)
    }

    @Test("XZEncoder Compress Data to file")
    func decodeToFile() throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".moc")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let encoder = XZEncoder()

        let data = TestData.generate(1024 * 1024 * 10)

        #expect(data.count >= 1024 * 1024 * 10)

        try encoder.encode(from: data, writeToUrl: fileURL)

        let result = try Data(contentsOf: fileURL)

        let decoder = XZDecoder()

        #expect(try decoder.decode(from: result) == data)
    }
}
