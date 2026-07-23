import Foundation
import Testing
import XzCompression

enum IOError: Error {
    case readError
    case writeError
}

struct XZDecoderTests {
    @Test("XZDecoder decode data")
    func decode() throws {
        let decoder = XZDecoder()

        #expect(try decoder.decode(from: TestData.compressed) == TestData.expected)
    }

    @Test("XZDecoder Error handling")
    func error() throws {
        let decoder = XZDecoder()

        #expect(throws: XZError.inputEofError) {
            try decoder.decode(from: TestData.inputEofError)
        }

        #expect(throws: XZError.noArchive) {
            try decoder.decode(from: TestData.incorrectMagic)
        }

        #expect(throws: XZError.crcError) {
            try decoder.decode(from: TestData.incorrectCrc)
        }

        #expect(throws: XZError.writeError) {
            try decoder.decode(from: TestData.compressed) { _ in
                throw IOError.writeError
            }
        }
    }

    @Test("XZDecoder Decompress to file")
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

        let decoder = XZDecoder()

        try decoder.decode(from: fileURL, writeToUrl: expectedURL)

        let result = try Data(contentsOf: expectedURL)

        #expect(result == TestData.expected)

        #expect(try decoder.decode(from: fileURL) == TestData.expected)
    }

    @Test("XZDecoder Decompress Data to file")
    func decodeToFile() throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".moc")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let decoder = XZDecoder()

        try decoder.decode(from: TestData.compressed, writeToUrl: fileURL)

        let result = try Data(contentsOf: fileURL)

        #expect(TestData.expected == result)
    }
}
