//
//  Created by Kurlovich Vitali on 7/24/26.
//

#ifndef CLZMA_INC_DECOMPRESS_STREAM_H
#define CLZMA_INC_DECOMPRESS_STREAM_H

#include "types.h"
#include "status.h"

lzma_ret_status lzma_decompress_stream(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress);

#endif
