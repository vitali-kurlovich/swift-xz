import Foundation
import Lzma
import Testing

enum IOError: Error {
    case readError
    case writeError
}

struct LzmaDecoderTests {
    @Test
    func `Decode small data`() throws {
        let decoder = LzmaDecoder()

        #expect(try decoder.decode(from: TestData.compressed) == TestData.expected)
    }

    @Test
    func `Decode with multiple reads`() throws {
        let configuration = LzmaDecoder.Configuration(inputBufferSize: 512)
        let decoder = LzmaDecoder(configuration: configuration)

        let data = TestData.compressed
        var position = data.startIndex
        let size = data.count

        var readCount = 0

        let result = try decoder.decode(
            read: { length in
                readCount += 1

                let rangeLength = Swift.min(length, size - position)

                if rangeLength == 0 {
                    return nil
                }

                let range = position ..< position + rangeLength
                position += rangeLength

                return data[range]
            },
        )

        #expect(readCount == 2)

        #expect(result == TestData.expected)
    }

    @Test
    func `Cancel handling`() throws {
        let decoder = LzmaDecoder(cancel: { true })
        #expect(throws: LzmaError.canceled) {
            try decoder.decode(from: TestData.compressed)
        }
    }

    @Test
    func Progress() throws {
        let configuration = LzmaDecoder.Configuration(
            inputBufferSize: 512,
            outputBufferSize: 512,
        )

        var progress: [[Int]] = []

        let decoder = LzmaDecoder(configuration: configuration, progress: { inSize, outSize in
            progress.append([inSize, outSize])
        })

        let data = TestData.compressed

        _ = try decoder.decode(from: data)
        #if canImport(Compression)
            #expect(progress == [[512, 512], [768, 1024], [768, 1368]])
        #else
            #expect(progress == [[512, 512], [512, 815], [768, 1327], [768, 1368]])
        #endif
    }

    @Test
    func `Error handling`() throws {
        let decoder = LzmaDecoder()

        #if canImport(Compression)
            #expect(throws: LzmaError.dataError) {
                try decoder.decode(from: TestData.incorrectMagic)
            }
        #else
            #expect(throws: LzmaError.formatError) {
                try decoder.decode(from: TestData.incorrectMagic)
            }
        #endif

        #expect(throws: LzmaError.dataError) {
            try decoder.decode(from: TestData.incorrectCrc)
        }

        #expect(throws: LzmaError.writeError) {
            try decoder.decode(from: TestData.compressed) { _ in
                throw IOError.writeError
            }
        }
    }

    @Test
    func `Decode to file`() throws {
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

    @Test
    func `Decode data to file`() throws {
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
