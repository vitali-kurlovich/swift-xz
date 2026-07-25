//
//  Created by Kurlovich Vitali on 7/25/26.
//

#ifndef CLZMA_INC_STREAM_H
#define CLZMA_INC_STREAM_H

#include "types.h"
#include "status.h"

typedef struct {
    size_t input_buffer_size;
    size_t output_buffer_size;
} lzma_buffer_config;

void lzma_buffer_config_init( lzma_buffer_config *config);

lzma_ret_status lzma_perform_stream(lzma_buffer_config config,
                                    lzma_stream *strm,
                                    ISeqInStream *inStream,
                                    ISeqOutStream *outStream,
                                    ICompressProgress *progress,
                                    IStreamCancelation *cancelation);

#endif
