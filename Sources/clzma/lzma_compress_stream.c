//
//  Created by Kurlovich Vitali on 7/25/26.
//

#include "lzma_compress_stream.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <lzma.h>

#define IN_BUF_MAX  8192
#define OUT_BUF_MAX 8192

lzma_ret_status lzma_compress_stream(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress,  uint32_t preset) {
    lzma_stream strm = LZMA_STREAM_INIT;

    lzma_ret_status status = STATUS_OK;
    
    // Initialize the encoder with preset (0-9) and CRC64 check
    lzma_ret ret = lzma_easy_encoder(&strm, preset, LZMA_CHECK_CRC64);
    if (ret != LZMA_OK) {
       
        Finalize(inStream);
        Finalize(outStream);
        Finalize(progress);
        
        return conv2ret_status(ret);
    }

    uint8_t inbuf[IN_BUF_MAX];
    uint8_t outbuf[OUT_BUF_MAX];

    strm.next_in = NULL;
    strm.avail_in = 0;
    strm.next_out = outbuf;
    strm.avail_out = sizeof(outbuf);

    lzma_action action = LZMA_RUN;

    while (true) {
        // Read input data when buffer is empty
        
        size_t inSize = sizeof(inbuf);
        
        lzma_io_status io_status = STATUS_IO_OK;
        
        ISeqInStream_Read(inStream, (void *)inbuf, &inSize, &io_status);
        
        if (io_status != STATUS_IO_OK) {
            status = STATUS_READ_ERROR;
            break;
        }
        
        if (inSize == 0) {
            ret = LZMA_STREAM_END;
            break;
        }
        
        // If we reached the end of the input stream/file, switch action to LZMA_FINISH
        if (inSize < sizeof(inbuf)) {
            action = LZMA_FINISH;
        }
        
        if (strm.avail_in == 0) {
            strm.next_in = inbuf;
            strm.avail_in = inSize;
        }

        // Perform compression
        ret = lzma_code(&strm, action);

        // Write output buffer to file when full or when stream completes
        if (strm.avail_out > 0 || ret == LZMA_STREAM_END) {
            size_t write_size = sizeof(outbuf) - strm.avail_out;
            
            size_t outSize = ISeqOutStream_Write(outStream, (void *)outbuf, write_size, &io_status);
            
            if (io_status != STATUS_IO_OK) {
                status = STATUS_WRITE_ERROR;
                break;
            }
            
            strm.next_out = outbuf;
            strm.avail_out = sizeof(outbuf);
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

