//
//  Created by Kurlovich Vitali on 7/25/26.
//

#ifndef CLZMA_INC_COMPRESS_STREAM_H
#define CLZMA_INC_COMPRESS_STREAM_H

#include "types.h"
#include "status.h"
#include "lzma_stream.h"

typedef struct {
    lzma_buffer_config buffer_config;
    uint32_t preset;
} lzma_compress_config;


void lzma_decoder_config_init( lzma_compress_config *config);

lzma_ret_status lzma_compress_stream(lzma_compress_config config,
                                     ISeqInStream *inStream,
                                     ISeqOutStream *outStream,
                                     ICompressProgress *progress,
                                     IStreamCancelation *cancelation);

#endif
