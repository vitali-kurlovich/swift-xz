//
//  Created by Kurlovich Vitali on 7/24/26.
//

#ifndef CLZMA_INC_DECOMPRESS_STREAM_H
#define CLZMA_INC_DECOMPRESS_STREAM_H

#include "types.h"
#include "status.h"

typedef struct {
    size_t input_buffer_size;
    size_t output_buffer_size;
} lzma_decompress_config;

void lzma_ds_config_init( lzma_decompress_config *config);

lzma_ret_status lzma_decompress_stream(lzma_decompress_config config, ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress);

#endif
