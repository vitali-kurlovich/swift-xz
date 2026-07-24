//
//  Created by Kurlovich Vitali on 7/24/26.
//

import Foundation

extension DataProtocol {
    var debugFormatted: String {
        let content = map { byte in
            String(byte, radix: 16)
        }.joined(separator: ",")

        return """
        count = \(count)
        bytes = [\(content)]
        """
    }
}
