
//
//  Created by Kurlovich Vitali on 7/24/26.
//

#include "lzma_decompress_stream.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <lzma.h>

void lzma_encoder_config_init(lzma_decompress_config *config) {
    lzma_buffer_config_init(config);
}

lzma_ret_status lzma_decompress_stream(lzma_decompress_config config,
                                       ISeqInStream *inStream,
                                       ISeqOutStream *outStream,
                                       IStreamProgress *progress,
                                       IStreamCancelation *cancelation) {
    
    // Initialize the lzma_stream structure
    lzma_stream strm = LZMA_STREAM_INIT;

    lzma_ret_status status = STATUS_OK;
    
    // Initialize the stream decoder
    // UINT64_MAX set as memory limit (unlimited); standard flags applied
    lzma_ret ret = lzma_stream_decoder(&strm, UINT64_MAX, LZMA_CONCATENATED);
    if (ret != LZMA_OK) {
        
        Finalize(inStream)
        Finalize(outStream)
        Finalize(progress)
        Finalize(cancelation)
        
        return conv2ret_status(ret);
    }
    
    return lzma_perform_stream(config, &strm, inStream, outStream, progress, cancelation);
}
