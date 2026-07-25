//
//  Created by Kurlovich Vitali on 7/25/26.
//


#ifndef CLZMA_INC_ERROR_H
#define CLZMA_INC_ERROR_H

#include <lzma.h>

typedef enum {
    STATUS_IO_OK = 0,
    STATUS_IO_READ_ERROR = 1,
    STATUS_IO_WRITE_ERROR = 2,
} lzma_io_status;


typedef enum {
    STATUS_OK                 = 0,

    STATUS_STREAM_END         = 1,

    STATUS_NO_CHECK           = 2,

    STATUS_UNSUPPORTED_CHECK  = 3,

    STATUS_GET_CHECK          = 4,

    STATUS_MEM_ERROR          = 5,

    STATUS_MEMLIMIT_ERROR     = 6,

    STATUS_FORMAT_ERROR       = 7,

    STATUS_OPTIONS_ERROR      = 8,

    STATUS_DATA_ERROR         = 9,

    STATUS_BUF_ERROR          = 10,

    STATUS_PROG_ERROR         = 11,

    STATUS_SEEK_NEEDED        = 12,
       
    STATUS_READ_ERROR         = 21,
    STATUS_WRITE_ERROR        = 22,
  
    STATUS_INTERNAL = 100
    
} lzma_ret_status;


lzma_ret_status conv2ret_status(lzma_ret ret);


#endif
