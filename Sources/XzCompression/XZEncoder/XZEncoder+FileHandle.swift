//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data
import class Foundation.FileHandle
import class Foundation.FileManager
import struct Foundation.URL

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension XZEncoder {
    func encode(from fileHandle: FileHandle, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(XZError) -> Data {
        var result = Data()
        try encode(from: fileHandle, write: { data in
            result.append(data)
        }, progress: progress)

        return result
    }

    func encode(from fileUrl: URL, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws -> Data {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        let data: Data

        do {
            data = try encode(from: readHandler, progress: progress)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()

        return data
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension XZEncoder {
    func encode(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(
        XZError
    ) {
        try encode(read: { length in
            try fileHandle.read(upToCount: length)
        }, write: writeFunc, progress: progress)
    }

    func encode(from fileUrl: URL, write writeFunc: @escaping (Data) throws -> Void, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)
        do {
            try encode(from: readHandler, write: writeFunc, progress: progress)
        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension XZEncoder {
    func encode(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(XZError) {
        try encode(read: read, write: { data in
            try writeHandle.write(contentsOf: data)
        }, progress: progress)
    }

    func encode(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
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
            try encode(
                read: read,
                writeToFile: writeHandler,
                progress: progress
            )

        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension XZEncoder {
    func encode(from data: Data, writeToFile writeHandle: FileHandle, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws(XZError) {
        try encode(from: data, write: { data in
            try writeHandle.write(contentsOf: data)
        }, progress: progress)
    }

    func encode(from data: Data, writeToUrl fileUrl: URL, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
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
            try encode(
                from: data,
                writeToFile: writeHandler,
                progress: progress
            )
        } catch {
            try writeHandler.close()
            throw error
        }

        try writeHandler.close()
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension XZEncoder {
    func encode(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
        try encode(from: fileHandle, write: { data in
            try writeHandle.write(contentsOf: data)
        }, progress: progress)
    }

    func encode(from fileHandle: FileHandle, writeToUrl fileUrl: URL, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
        try encode(read: { length in
            try fileHandle.read(upToCount: length)
        }, writeToUrl: fileUrl, progress: progress)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension XZEncoder {
    func encode(from fileUrl: URL, writeToFile writeHandle: FileHandle, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try encode(
                from: readHandler,
                writeToFile: writeHandle,
                progress: progress
            )

        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }

    func encode(from fileUrl: URL, writeToUrl fileWriteUrl: URL, progress: @escaping (Int, Int) -> Bool = { _, _ in false }) throws {
        let readHandler = try FileHandle(forReadingFrom: fileUrl)

        do {
            try encode(
                from: readHandler,
                writeToUrl: fileWriteUrl,
                progress: progress
            )

        } catch {
            try readHandler.close()
            throw error
        }

        try readHandler.close()
    }
}
