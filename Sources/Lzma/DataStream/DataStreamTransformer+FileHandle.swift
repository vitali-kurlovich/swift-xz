//
//  Created by Kurlovich Vitali on 7/26/26.
//

import struct Foundation.Data
import class Foundation.FileHandle
import class Foundation.FileManager
import struct Foundation.URL

extension DataStreamTransformer {
    func transform(from fileHandle: FileHandle) throws -> Data {
        var result = Data()
        try transform(from: fileHandle, write: { result.append($0) })
        return result
    }

    func transform(from fileUrl: URL) throws -> Data {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        let data: Data

        do {
            data = try transform(from: readHandler)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()

        return data
    }
}

extension DataStreamTransformer {
    func transform(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void) throws {
        try transform(read: { try fileHandle.read(upToCount: $0) }, write: writeFunc)
    }

    func transform(from fileUrl: URL, write writeFunc: @escaping (Data) throws -> Void) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)
        do {
            try transform(from: readHandler, write: writeFunc)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}

extension DataStreamTransformer {
    func transform(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle) throws {
        try transform(read: read, write: { try writeHandle.write(contentsOf: $0) })
    }

    func transform(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL) throws {
        let path: String = if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            fileUrl.path()
        } else {
            fileUrl.path
        }

        if FileManager.default.fileExists(atPath: path) == false {
            FileManager.default.createFile(atPath: path, contents: nil)
        }

        let writeHandler = try FileHandle(forWritingTo: fileUrl)

        do {
            try transform(read: read, writeToFile: writeHandler)
        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

extension DataStreamTransformer {
    func transform(from data: Data, writeToFile writeHandle: FileHandle) throws {
        try transform(from: data, write: { try writeHandle.write(contentsOf: $0) })
    }

    func transform(from data: Data, writeToUrl fileUrl: URL) throws {
        let path: String = if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            fileUrl.path()
        } else {
            fileUrl.path
        }

        if FileManager.default.fileExists(atPath: path) == false {
            FileManager.default.createFile(atPath: path, contents: nil)
        }

        let writeHandler = try FileHandle(forWritingTo: fileUrl)
        do {
            try transform(from: data, writeToFile: writeHandler)
        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

extension DataStreamTransformer {
    func transform(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle) throws {
        try transform(from: fileHandle, write: { try writeHandle.write(contentsOf: $0) })
    }

    func transform(from fileHandle: FileHandle, writeToUrl fileUrl: URL) throws {
        try transform(read: { try fileHandle.read(upToCount: $0) }, writeToUrl: fileUrl)
    }
}

extension DataStreamTransformer {
    func transform(from fileUrl: URL, writeToFile writeHandle: FileHandle) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try transform(from: readHandler, writeToFile: writeHandle)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }

    func transform(from fileUrl: URL, writeToUrl fileWriteUrl: URL) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try transform(from: readHandler, writeToUrl: fileWriteUrl)

        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}
