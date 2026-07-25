import Foundation
import Lzma
import Testing

enum IOError: Error {
    case readError
    case writeError
}

struct LzmaDecoderTests {
    @Test("Decode small data")
    func decode() throws {
        let decoder = LzmaDecoder()

        #expect(try decoder.decode(from: TestData.compressed) == TestData.expected)
    }

    @Test("Decode with multiple reads")
    func decodeMultipleReads() throws {
        let decoder = LzmaDecoder()

        let configuration = LzmaDecoder.Configuration(inputBufferSize: 512)
        let data = TestData.compressed
        var position = data.startIndex
        let size = data.count

        var readCount = 0

        let result = try decoder.decode(
            configuration: configuration,
            read: { length in
                readCount += 1

                let rangeLength = Swift.min(length, size - position)

                if rangeLength == 0 {
                    return nil
                }

                let range = position ..< position + rangeLength
                position += rangeLength

                return data[range]
            }
        )

        #expect(readCount == 2)

        #expect(result == TestData.expected)
    }

    @Test("Cancel handling")
    func cancel() throws {
        let decoder = LzmaDecoder()
        #expect(throws: LzmaError.canceled) {
            try decoder.decode(from: TestData.compressed, cancel: { true })
        }
    }

    @Test("Progress")
    func progress() throws {
        let decoder = LzmaDecoder()

        let configuration = LzmaDecoder.Configuration(
            inputBufferSize: 512,
            outputBufferSize: 512
        )

        let data = TestData.compressed

        var progress: [[Int]] = []

        _ = try decoder.decode(configuration: configuration,
                               from: data,
                               progress: { inSize, outSize in
                                   progress.append([inSize, outSize])
                               })

        #expect(progress == [[512, 512], [512, 815], [768, 1327], [768, 1368]])
    }

    @Test("Error handling")
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

    @Test("Decode to file")
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

    @Test("Decode data to file")
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
