
//
//  Created by Kurlovich Vitali on 7/25/26.
//

#include "lzma_stream.h"

void lzma_buffer_config_init( lzma_buffer_config *config) {
    config->input_buffer_size = 8192;
    config->output_buffer_size = 8192;
}

lzma_ret_status lzma_perform_stream(lzma_buffer_config config,
                                    lzma_stream *strm,
                                    ISeqInStream *inStream,
                                    ISeqOutStream *outStream,
                                    IStreamProgress *progress,
                                    IStreamCancelation *cancelation) {
 
    lzma_ret_status status = STATUS_OK;
    
    uint8_t in_buf[config.input_buffer_size];
    uint8_t out_buf[config.output_buffer_size];

    strm->next_in = NULL;
    strm->avail_in = 0;
    strm->next_out = out_buf;
    strm->avail_out = config.output_buffer_size;
    
    lzma_action action = LZMA_RUN;
    
    bool isEof = false;
    
    UInt64 inputSize = 0;
    UInt64 outputSize = 0;
    
    while (true) {
        
        bool cancel = false;
        
        size_t inSize = config.input_buffer_size;
        
        lzma_io_status io_status = STATUS_IO_OK;
        lzma_ret ret = LZMA_OK;
        
        if (strm->avail_in == 0 && isEof == false) {
            
            CheckStreamCancel(cancelation, &cancel)
            
            if (cancel == true) {
                status = STATUS_CANCELED;
                break;
            }
            
            ISeqInStream_Read(inStream, (void *)in_buf, &inSize, &io_status)
            
            inputSize += inSize;
            
            if (io_status != STATUS_IO_OK) {
                status = STATUS_READ_ERROR;
                break;
            }
            
            if (inSize < config.input_buffer_size) {
                isEof = true;
                action = LZMA_FINISH;
            }
            
            strm->next_in = in_buf;
            strm->avail_in = inSize;
        }
        
        CheckStreamCancel(cancelation, &cancel)
        
        if (cancel == true) {
            status = STATUS_CANCELED;
            break;
        }
       
        // Run the decompressor
        ret = lzma_code(strm, action);

        // Process produced output, if any
        if (strm->avail_out < config.output_buffer_size) {
            
            CheckStreamCancel(cancelation, &cancel)
            
            if (cancel == true) {
                status = STATUS_CANCELED;
                break;
            }
            
            size_t write_size = config.output_buffer_size - strm->avail_out;
            size_t outSize = ISeqOutStream_Write(outStream, (void *)out_buf, write_size, &io_status);
            
            outputSize += outSize;
            
            ICompress_Progress(progress, inputSize, outputSize)
            
            if (io_status != STATUS_IO_OK) {
                status = STATUS_WRITE_ERROR;
                break;
            }
            
            // Reset output buffer parameters
            strm->next_out = out_buf;
            strm->avail_out = sizeof(out_buf);
        }

        // Handle return status
        if (ret == LZMA_STREAM_END) {
            status = STATUS_OK;
            break;
        }
        
        if (status == STATUS_CANCELED) {
            break;
        }
        
        if (ret != LZMA_OK) {
            status = conv2ret_status(ret);
            break;
        }
    }
    
    lzma_end(strm);
    
    Finalize(inStream);
    Finalize(outStream);
    Finalize(progress);
    Finalize(cancelation);
    
    return status;
}
