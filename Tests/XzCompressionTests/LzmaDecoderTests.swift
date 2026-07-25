import Foundation
import Testing
import XzCompression

enum IOError: Error {
    case readError
    case writeError
}

struct LzmaDecoderTests {
    @Test("Decoder decode data")
    func decode() throws {
        let decoder = LzmaDecoder()

        #expect(try decoder.decode(from: TestData.compressed) == TestData.expected)
    }

    @Test("Decoder error handling")
    func error() throws {
        let decoder = LzmaDecoder()

        #expect(throws: LzmaError.formatError) {
            try decoder.decode(from: TestData.incorrectMagic)
        }

        #expect(throws: LzmaError.dataError) {
            try decoder.decode(from: TestData.incorrectCrc)
        }

        #expect(throws: LzmaError.writeError) {
            try decoder.decode(from: TestData.compressed) { _ in
                throw IOError.writeError
            }
        }
    }

    @Test("Decoder decompress to file")
    func fileDecode() throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".moc")
        let expectedURL = tempDir.appendingPathComponent(UUID().uuidString + ".txt")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: expectedURL)
        }

        // 4. Write mock data to the temporary file
        try TestData.compressed.write(to: fileURL, options: [.atomic])

        let decoder = LzmaDecoder()

        try decoder.decode(from: fileURL, writeToUrl: expectedURL)

        let result = try Data(contentsOf: expectedURL)

        #expect(result == TestData.expected)

        #expect(try decoder.decode(from: fileURL) == TestData.expected)
    }

    @Test("Decoder decompress data to file")
    func decodeToFile() throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".moc")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let decoder = LzmaDecoder()

        try decoder.decode(from: TestData.compressed, writeToUrl: fileURL)

        let result = try Data(contentsOf: fileURL)

        #expect(TestData.expected == result)
    }
}
