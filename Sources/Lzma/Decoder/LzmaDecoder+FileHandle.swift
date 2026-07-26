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
        try _decoder.transform(from: fileHandle)
    }

    func decode(from fileUrl: URL) throws -> Data {
        try _decoder.transform(from: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void) throws {
        try _decoder.transform(from: fileHandle, write: writeFunc)
    }

    func decode(from fileUrl: URL, write writeFunc: @escaping (Data) throws -> Void) throws {
        try _decoder.transform(from: fileUrl, write: writeFunc)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle) throws {
        try _decoder.transform(read: read, writeToFile: writeHandle)
    }

    func decode(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL) throws {
        try _decoder.transform(read: read, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from data: Data, writeToFile writeHandle: FileHandle) throws {
        try _decoder.transform(from: data, writeToFile: writeHandle)
    }

    func decode(from data: Data, writeToUrl fileUrl: URL) throws {
        try _decoder.transform(from: data, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle) throws {
        try _decoder.transform(from: fileHandle, writeToFile: writeHandle)
    }

    func decode(from fileHandle: FileHandle, writeToUrl fileUrl: URL) throws {
        try _decoder.transform(from: fileHandle, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaDecoder {
    func decode(from fileUrl: URL, writeToFile writeHandle: FileHandle) throws {
        try _decoder.transform(from: fileUrl, writeToFile: writeHandle)
    }

    func decode(from fileUrl: URL, writeToUrl fileWriteUrl: URL) throws {
        try _decoder.transform(from: fileUrl, writeToUrl: fileWriteUrl)
    }
}
