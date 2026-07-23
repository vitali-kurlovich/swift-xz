//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data
import class Foundation.FileHandle
import class Foundation.FileManager
import struct Foundation.URL

public extension XZEncoder {
    func encode(from fileHandle: FileHandle) throws(XZError) -> Data {
        var result = Data()
        try encode(from: fileHandle, write: { data in
            result.append(data)
        })

        return result
    }

    func encode(from fileUrl: URL) throws -> Data {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        let data: Data

        do {
            data = try encode(from: readHandler)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()

        return data
    }
}

public extension XZEncoder {
    func encode(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void) throws(
        XZError
    ) {
        try encode(read: { length in
            try fileHandle.read(upToCount: length)
        }, write: writeFunc)
    }

    func encode(from fileUrl: URL, write writeFunc: @escaping (Data) throws -> Void) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)
        do {
            try encode(from: readHandler, write: writeFunc)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}

public extension XZEncoder {
    func encode(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle) throws(XZError) {
        try encode(read: read, write: { data in
            try writeHandle.write(contentsOf: data)
        })
    }

    func encode(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL) throws {
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
            try encode(read: read, writeToFile: writeHandler)

        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

public extension XZEncoder {
    func encode(from data: Data, writeToFile writeHandle: FileHandle) throws(XZError) {
        try encode(from: data) { data in
            try writeHandle.write(contentsOf: data)
        }
    }

    func encode(from data: Data, writeToUrl fileUrl: URL) throws {
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
            try encode(from: data, writeToFile: writeHandler)
        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

public extension XZEncoder {
    func encode(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle) throws {
        try encode(from: fileHandle) { data in
            try writeHandle.write(contentsOf: data)
        }
    }

    func encode(from fileHandle: FileHandle, writeToUrl fileUrl: URL) throws {
        try encode(read: { length in
            try fileHandle.read(upToCount: length)
        }, writeToUrl: fileUrl)
    }
}

public extension XZEncoder {
    func encode(from fileUrl: URL, writeToFile writeHandle: FileHandle) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try encode(from: readHandler, writeToFile: writeHandle)

        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }

    func encode(from fileUrl: URL, writeToUrl fileWriteUrl: URL) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try encode(from: readHandler, writeToUrl: fileWriteUrl)

        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}
