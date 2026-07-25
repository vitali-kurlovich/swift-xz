//
//  Created by Kurlovich Vitali on 7/25/26.
//

#ifndef CLZMA_INC_COMPRESS_STREAM_H
#define CLZMA_INC_COMPRESS_STREAM_H

#include "types.h"
#include "status.h"

lzma_ret_status lzma_compress_stream(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress,  uint32_t preset);

#endif
