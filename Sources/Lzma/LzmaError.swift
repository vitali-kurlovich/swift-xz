//
//  Created by Kurlovich Vitali on 7/23/26.
//

import clzma

public enum LzmaError: Error, Sendable {
    /**
     * Cannot allocate memory
     *
     * Memory allocation failed, or the size of the allocation
     * would be greater than SIZE_MAX.
     *
     * Due to internal implementation reasons, the coding cannot
     * be continued even if more memory were made available after
     * LZMA_MEM_ERROR.
     */
    case memoryError

    /**
     * Memory usage limit was reached
     *
     * Decoder would need more memory than allowed by the
     * specified memory usage limit. To continue decoding,
     * the memory usage limit has to be increased with
     * lzma_memlimit_set().
     *
     * liblzma 5.2.6 and earlier had a bug in single-threaded .xz
     * decoder (lzma_stream_decoder()) which made it impossible
     * to continue decoding after LZMA_MEMLIMIT_ERROR even if
     * the limit was increased using lzma_memlimit_set().
     * Other decoders worked correctly.
     */
    case memoryLimitError

    /*
     * File format not recognized
     *
     * The decoder did not recognize the input as supported file
     * format. This error can occur, for example, when trying to
     * decode .lzma format file with lzma_stream_decoder,
     * because lzma_stream_decoder accepts only the .xz format.
     */

    case formatError

    /*
     *  Invalid or unsupported options
     *
     * Invalid or unsupported options, for example
     *  - unsupported filter(s) or filter options; or
     *  - reserved bits set in headers (decoder only).
     *
     * Rebuilding liblzma with more features enabled, or
     * upgrading to a newer version of liblzma may help.
     */

    case optionsError

    /*
     * Data is corrupt
     *
     * The usage of this return value is different in encoders
     * and decoders. In both encoder and decoder, the coding
     * cannot continue after this error.
     *
     * Encoders return this if size limits of the target file
     * format would be exceeded. These limits are huge, thus
     * getting this error from an encoder is mostly theoretical.
     * For example, the maximum compressed and uncompressed
     * size of a .xz Stream is roughly 8 EiB (2^63 bytes).
     *
     * Decoders return this error if the input data is corrupt.
     * This can mean, for example, invalid CRC32 in headers
     * or invalid check of uncompressed data.
     */

    case dataError

    /*
     *  Programming error
     *
     * This indicates that the arguments given to the function are
     * invalid or the internal state of the decoder is corrupt.
     *   - Function arguments are invalid or the structures
     *     pointed by the argument pointers are invalid
     *     e.g. if strm->next_out has been set to NULL and
     *     strm->avail_out > 0 when calling lzma_code().
     *   - lzma_* functions have been called in wrong order
     *     e.g. lzma_code() was called right after lzma_end().
     *   - If errors occur randomly, the reason might be flaky
     *     hardware.
     *
     * If you think that your code is correct, this error code
     * can be a sign of a bug in liblzma. See the documentation
     * how to report bugs.
     */

    case progError

    case readError
    case writeError

    case canceled

    case unknownError
}

extension LzmaError {
    init(_ status: lzma_ret_status) {
        switch status {
        case STATUS_MEM_ERROR:
            self = .memoryError
        case STATUS_MEMLIMIT_ERROR:
            self = .memoryLimitError
        case STATUS_FORMAT_ERROR:
            self = .formatError
        case STATUS_OPTIONS_ERROR:
            self = .optionsError
        case STATUS_DATA_ERROR:
            self = .dataError
        case STATUS_PROG_ERROR:
            self = .progError
        case STATUS_READ_ERROR:
            self = .readError
        case STATUS_WRITE_ERROR:
            self = .writeError
        case STATUS_CANCELED:
            self = .canceled
        default:
            self = .unknownError
        }
    }
}
