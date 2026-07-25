//
//  Created by Kurlovich Vitali on 7/25/26.
//

#include "status.h"

lzma_ret_status conv2ret_status(lzma_ret ret) {
    switch (ret) {
        
        case LZMA_OK:
            return STATUS_OK;

        case LZMA_STREAM_END:
            return STATUS_STREAM_END;

        case LZMA_NO_CHECK:
            return STATUS_NO_CHECK;
            
        case LZMA_UNSUPPORTED_CHECK:
            return STATUS_UNSUPPORTED_CHECK;

        case LZMA_GET_CHECK:
            return STATUS_GET_CHECK;
            
        case LZMA_MEM_ERROR:
            return STATUS_MEM_ERROR;
           
        case LZMA_MEMLIMIT_ERROR:
            return STATUS_MEMLIMIT_ERROR;
           
        case LZMA_FORMAT_ERROR:
            return STATUS_FORMAT_ERROR;
            
        case LZMA_OPTIONS_ERROR:
            return STATUS_OPTIONS_ERROR;
            
        case LZMA_DATA_ERROR:
            return STATUS_DATA_ERROR;
            
        case LZMA_BUF_ERROR:
            return STATUS_BUF_ERROR;
            
        case LZMA_PROG_ERROR:
            return STATUS_PROG_ERROR;
            
        case LZMA_SEEK_NEEDED:
            return STATUS_SEEK_NEEDED;
            
        case LZMA_RET_INTERNAL1:
        case LZMA_RET_INTERNAL2:
        case LZMA_RET_INTERNAL3:
        case LZMA_RET_INTERNAL4:
        case LZMA_RET_INTERNAL5:
        case LZMA_RET_INTERNAL6:
        case LZMA_RET_INTERNAL7:
        case LZMA_RET_INTERNAL8:
            return STATUS_INTERNAL;
            
    }
}
