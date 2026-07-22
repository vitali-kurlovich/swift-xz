// The Swift Programming Language
// https://docs.swift.org/swift-book

import CLzma

typealias ReadCallback = @convention(c) (
    UnsafePointer<ISeqInStream_>?,
    UnsafeMutableRawPointer?,
    UnsafeMutablePointer<Int>?
) -> Int32

typealias WriteCallback = @convention(c) (UnsafePointer<ISeqOutStream_>?, UnsafeRawPointer?, Int) -> Int

