//
//  Created by Kurlovich Vitali on 7/23/26.
//

import Foundation
import Lzma
import Testing

struct LzmaEncoderTests { func encode() throws {
    let encoder = LzmaEncoder()

    let data = TestData.expected

    let result = try encoder.encode(from: data)

    #expect(data != result)

    let decoder = LzmaDecoder()
    #expect(try decoder.decode(from: result) == data)
}

@Test("Encoder cancel handling")
func cancel() throws {
    let encoder = LzmaEncoder()
    #expect(throws: LzmaError.canceled) {
        try encoder.encode(from: TestData.compressed, cancel: { true })
    }
}

@Test("Encoder error handling")
func error() throws {
    let encoder = LzmaEncoder()

    #expect(throws: LzmaError.writeError) {
        try encoder.encode(from: TestData.expected) { _ in
            throw IOError.writeError
        }
    }
}

@Test("Encoder encode to file")
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

    let encoder = LzmaEncoder()

    try encoder.encode(from: fileURL, writeToUrl: compessedURL)

    let decoder = LzmaDecoder()

    #expect(try decoder.decode(from: compessedURL) == TestData.expected)
}

@Test("Encoder earge dataset")
func decodeLargeData() throws {
    let encoder = LzmaEncoder()
    let decoder = LzmaDecoder()

    let data = TestData.generate(1024 * 1024 * 10)
    #expect(data.count >= 1024 * 1024 * 10)

    let compressed = try encoder.encode(from: data)

    #expect(compressed.isEmpty == false)

    #expect(try decoder.decode(from: compressed) == data)
}

@Test("Encoder Compress Data to file")
func decodeToFile() throws {
    // 1. Get the system temporary directory URL
    let tempDir = FileManager.default.temporaryDirectory

    // 2. Create a unique filename for isolation
    let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".moc")

    // 3. Clean up the file automatically when the test finishes
    defer {
        try? FileManager.default.removeItem(at: fileURL)
    }

    let encoder = LzmaEncoder()
    let decoder = LzmaDecoder()

    let data = TestData.generate(1024 * 1024 * 10)

    #expect(data.count >= 1024 * 1024 * 10)

    try encoder.encode(from: data, writeToUrl: fileURL)

    let result = try Data(contentsOf: fileURL)

    #expect(result.isEmpty == false)

    #expect(try decoder.decode(from: result) == data)
}
}
