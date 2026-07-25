
//
//  Created by Kurlovich Vitali on 7/24/26.
//

#include "lzma_decompress_stream.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <lzma.h>

#define IN_BUF_MAX  8192
#define OUT_BUF_MAX 8192

lzma_ret_status lzma_decompress_stream(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress) {
    
    // 1. Initialize the lzma_stream structure
    lzma_stream strm = LZMA_STREAM_INIT;

    lzma_ret_status status = STATUS_OK;
    
    // 2. Initialize the stream decoder
    // UINT64_MAX set as memory limit (unlimited); standard flags applied
    lzma_ret ret = lzma_stream_decoder(&strm, UINT64_MAX, LZMA_CONCATENATED);
    if (ret != LZMA_OK) {
        
        Finalize(inStream);
        Finalize(outStream);
        Finalize(progress);
        
        return conv2ret_status(ret);
    }

    uint8_t in_buf[IN_BUF_MAX];
    uint8_t out_buf[OUT_BUF_MAX];

    lzma_action action = LZMA_RUN;

    strm.next_in = NULL;
    strm.avail_in = 0;
    strm.next_out = out_buf;
    strm.avail_out = OUT_BUF_MAX;

    bool isEof = false;
    
    while (true) {
        // Refill input buffer if empty and not at EOF
        
        size_t inSize = IN_BUF_MAX;
        
        lzma_io_status io_status = STATUS_IO_OK;
        if (strm.avail_in == 0 && isEof == false) {
            ISeqInStream_Read(inStream, (void *)in_buf, &inSize, &io_status);
            
            if (io_status != STATUS_IO_OK) {
                status = STATUS_READ_ERROR;
                break;
            }
            
            if (inSize < IN_BUF_MAX) {
                isEof = true;
                action = LZMA_FINISH;
            }
            
            strm.next_in = in_buf;
            strm.avail_in = inSize;
        }
        
       
        // Run the decompressor
        ret = lzma_code(&strm, action);

        // Process produced output, if any
        if (strm.avail_out < sizeof(out_buf)) {
            size_t write_size = sizeof(out_buf) - strm.avail_out;
            size_t outSize = ISeqOutStream_Write(outStream, (void *)out_buf, write_size, &io_status );
            
            if (io_status != STATUS_IO_OK) {
                status = STATUS_WRITE_ERROR;
                break;
            }
            
            // Reset output buffer parameters
            strm.next_out = out_buf;
            strm.avail_out = sizeof(out_buf);
        }

        // Handle return status
        if (ret == LZMA_STREAM_END) {
            status = STATUS_OK;
            break;
        }
        
        if (ret != LZMA_OK) {
            status = conv2ret_status(ret);
            break;
        }
    }
    
    lzma_end(&strm);
    
    Finalize(inStream);
    Finalize(outStream);
    Finalize(progress);
    
    return status;
}
