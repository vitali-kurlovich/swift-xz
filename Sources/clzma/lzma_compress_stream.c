//
//  Created by Kurlovich Vitali on 7/25/26.
//

#include "lzma_compress_stream.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <lzma.h>

void lzma_cs_config_init(lzma_compress_config *config) {
    config->input_buffer_size = 8192;
    config->output_buffer_size = 8192;
    config->preset = 6;
}

lzma_ret_status lzma_compress_stream(lzma_compress_config config, ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress) {
    lzma_stream strm = LZMA_STREAM_INIT;

    lzma_ret_status status = STATUS_OK;
    
    // Initialize the encoder with preset (0-9) and CRC64 check
    lzma_ret ret = lzma_easy_encoder(&strm, config.preset, LZMA_CHECK_CRC64);
    if (ret != LZMA_OK) {
       
        Finalize(inStream);
        Finalize(outStream);
        Finalize(progress);
        
        return conv2ret_status(ret);
    }

    uint8_t inbuf[config.input_buffer_size];
    uint8_t outbuf[config.output_buffer_size];

    strm.next_in = NULL;
    strm.avail_in = 0;
    strm.next_out = outbuf;
    strm.avail_out = config.output_buffer_size;

    lzma_action action = LZMA_RUN;

    while (true) {
        // Read input data when buffer is empty
        
        size_t inSize = config.input_buffer_size;
        
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
        if (inSize < config.input_buffer_size) {
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
            size_t write_size = config.output_buffer_size - strm.avail_out;
            
            size_t outSize = ISeqOutStream_Write(outStream, (void *)outbuf, write_size, &io_status);
            
            if (io_status != STATUS_IO_OK) {
                status = STATUS_WRITE_ERROR;
                break;
            }
            
            strm.next_out = outbuf;
            strm.avail_out = config.output_buffer_size;
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

