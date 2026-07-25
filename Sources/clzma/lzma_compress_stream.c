//
//  Created by Kurlovich Vitali on 7/25/26.
//

#include "lzma_compress_stream.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <lzma.h>

void lzma_decoder_config_init(lzma_compress_config *config) {
    lzma_buffer_config_init(&config->buffer_config);
    config->preset = 6;
}

lzma_ret_status lzma_compress_stream(lzma_compress_config config,
                                     ISeqInStream *inStream,
                                     ISeqOutStream *outStream,
                                     ICompressProgress *progress,
                                     IStreamCancelation *cancelation) {
    
    // Initialize the lzma_stream structure
    lzma_stream strm = LZMA_STREAM_INIT;

    lzma_ret_status status = STATUS_OK;
    
    // Initialize the encoder with preset (0-9) and CRC64 check
    lzma_ret ret = lzma_easy_encoder(&strm, config.preset, LZMA_CHECK_CRC64);
    if (ret != LZMA_OK) {
       
        Finalize(inStream);
        Finalize(outStream);
        Finalize(progress);
        Finalize(cancelation);
        
        return conv2ret_status(ret);
    }
    
    return lzma_perform_stream(config.buffer_config, &strm, inStream, outStream, progress, cancelation);
}

