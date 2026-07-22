//
//  Created by Kurlovich Vitali on 7/23/26.
//

public enum XZError: Int32, Error, Sendable {
    case dataError = 1
    case memError = 2
    case crcError = 3
    case unsupportedError = 4

    case paramError = 5

    case inputEofError = 6
    case outputEofError = 7

    case readError = 8
    case writeError = 9

    case progressError = 10
    case fail = 11
    case threadError = 12

    case archiveError = 16
    case noArchive = 17

    case unknownError = -1
}

