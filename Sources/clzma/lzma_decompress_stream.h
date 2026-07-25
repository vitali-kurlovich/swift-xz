//
//  Created by Kurlovich Vitali on 7/24/26.
//

#ifndef CLZMA_INC_DECOMPRESS_STREAM_H
#define CLZMA_INC_DECOMPRESS_STREAM_H

#include "types.h"
#include "status.h"

#include "lzma_stream.h"

typedef lzma_buffer_config  lzma_decompress_config;

void lzma_encoder_config_init( lzma_decompress_config *config);

lzma_ret_status lzma_decompress_stream(lzma_decompress_config config, ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress);

#endif
