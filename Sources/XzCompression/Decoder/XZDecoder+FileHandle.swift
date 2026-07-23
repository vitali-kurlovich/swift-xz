//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data
import class Foundation.FileHandle
import class Foundation.FileManager
import struct Foundation.URL

public extension XZDecoder {
    func decode(from fileHandle: FileHandle) throws(XZError) -> Data {
        var result = Data()
        try decode(from: fileHandle, write: { data in
            result.append(data)
        })

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

public extension XZDecoder {
    func decode(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle) throws(XZError) {
        try decode(read: read, write: { data in
            try writeHandle.write(contentsOf: data)
        })
    }

    func decode(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL) throws {
        let path: String

        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            path = fileUrl.path()
        } else {
            path = fileUrl.path
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

public extension XZDecoder {
    func decode(from data: Data, writeToFile writeHandle: FileHandle) throws(XZError) {
        try decode(from: data) { data in
            try writeHandle.write(contentsOf: data)
        }
    }

    func decode(from data: Data, writeToUrl fileUrl: URL) throws {
        let path: String

        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            path = fileUrl.path()
        } else {
            path = fileUrl.path
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

public extension XZDecoder {
    func decode(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void) throws(
        XZError
    ) {
        try decode(read: { length in
            try fileHandle.read(upToCount: length)
        }, write: writeFunc)
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

public extension XZDecoder {
    func decode(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle) throws {
        try decode(from: fileHandle) { data in
            try writeHandle.write(contentsOf: data)
        }
    }

    func decode(from fileHandle: FileHandle, writeToUrl fileUrl: URL) throws {
        try decode(read: { length in
            try fileHandle.read(upToCount: length)
        }, writeToUrl: fileUrl)
    }
}

public extension XZDecoder {
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
