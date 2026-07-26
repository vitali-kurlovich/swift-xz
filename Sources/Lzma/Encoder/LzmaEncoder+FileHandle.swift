//
//  Created by Kurlovich Vitali on 7/23/26.
//

import struct Foundation.Data
import class Foundation.FileHandle
import struct Foundation.URL

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaEncoder {
    func encode(from fileHandle: FileHandle) throws -> Data {
        try _encoder.transform(from: fileHandle)
    }

    func encode(from fileUrl: URL) throws -> Data {
        try _encoder.transform(from: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaEncoder {
    func encode(from fileHandle: FileHandle, write writeFunc: @escaping (Data) throws -> Void) throws {
        try _encoder.transform(from: fileHandle, write: writeFunc)
    }

    func encode(from fileUrl: URL, write writeFunc: @escaping (Data) throws -> Void) throws {
        try _encoder.transform(from: fileUrl, write: writeFunc)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaEncoder {
    func encode(read: @escaping (Int) throws -> Data?, writeToFile writeHandle: FileHandle) throws {
        try _encoder.transform(read: read, writeToFile: writeHandle)
    }

    func encode(read: @escaping (Int) throws -> Data?, writeToUrl fileUrl: URL) throws {
        try _encoder.transform(read: read, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaEncoder {
    func encode(from data: Data, writeToFile writeHandle: FileHandle) throws {
        try _encoder.transform(from: data, writeToFile: writeHandle)
    }

    func encode(from data: Data, writeToUrl fileUrl: URL) throws {
        try _encoder.transform(from: data, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaEncoder {
    func encode(from fileHandle: FileHandle, writeToFile writeHandle: FileHandle) throws {
        try _encoder.transform(from: fileHandle, writeToFile: writeHandle)
    }

    func encode(from fileHandle: FileHandle, writeToUrl fileUrl: URL) throws {
        try _encoder.transform(from: fileHandle, writeToUrl: fileUrl)
    }
}

@available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
public extension LzmaEncoder {
    func encode(from fileUrl: URL, writeToFile writeHandle: FileHandle) throws {
        try _encoder.transform(from: fileUrl, writeToFile: writeHandle)
    }

    func encode(from fileUrl: URL, writeToUrl fileWriteUrl: URL) throws {
        try _encoder.transform(from: fileUrl, writeToUrl: fileWriteUrl)
    }
}
