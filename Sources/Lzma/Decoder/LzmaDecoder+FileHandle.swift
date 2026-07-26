//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data
import class Foundation.FileHandle
import class Foundation.FileManager
import struct Foundation.URL

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileHandle: FileHandle) throws -> Data {
        var result = Data()
        try decode(from: fileHandle, write: { result.append($0) })
        return result
    }

    func decode(from fileUrl: URL) throws -> Data {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        let data: Data

        do {
            data = try decode(from: readHandler)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()

        return data
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void) throws {
        try decode(read: { try fileHandle.read(upToCount: $0) }, write: writeFunc)
    }

    func decode(from fileUrl: URL, write writeFunc: @escaping (Data) throws -> Void) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)
        do {
            try decode(from: readHandler, write: writeFunc)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle) throws {
        try decode(read: read, write: { try writeHandle.write(contentsOf: $0) })
    }

    func decode(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL) throws {
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
            try decode(read: read, writeToFile: writeHandler)

        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from data: Data, writeToFile writeHandle: FileHandle) throws {
        try decode(from: data, write: { try writeHandle.write(contentsOf: $0) })
    }

    func decode(from data: Data, writeToUrl fileUrl: URL) throws {
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
            try decode(from: data, writeToFile: writeHandler)
        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle) throws {
        try decode(from: fileHandle, write: { try writeHandle.write(contentsOf: $0) })
    }

    func decode(from fileHandle: FileHandle, writeToUrl fileUrl: URL) throws {
        try decode(read: { try fileHandle.read(upToCount: $0) }, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileUrl: URL, writeToFile writeHandle: FileHandle) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try decode(from: readHandler, writeToFile: writeHandle)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }

    func decode(from fileUrl: URL, writeToUrl fileWriteUrl: URL) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try decode(from: readHandler, writeToUrl: fileWriteUrl)

        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}
