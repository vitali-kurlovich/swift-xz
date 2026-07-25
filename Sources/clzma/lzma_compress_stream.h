//
//  Created by Kurlovich Vitali on 7/25/26.
//

#ifndef CLZMA_INC_COMPRESS_STREAM_H
#define CLZMA_INC_COMPRESS_STREAM_H

#include "types.h"
#include "status.h"

typedef struct {
    size_t input_buffer_size;
    size_t output_buffer_size;
    uint32_t preset;
} lzma_compress_config;

void lzma_cs_config_init( lzma_compress_config *config);

lzma_ret_status lzma_compress_stream(lzma_compress_config config, ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress);

#endif
