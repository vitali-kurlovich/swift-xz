//
//  Created by Kurlovich Vitali on 7/24/26.
//

#ifndef CLZMA_INC_TYPES_H
#define CLZMA_INC_TYPES_H

#import "macros.h"
#include "status.h"

#include <lzma.h>
#include <stddef.h>
#include <stdbool.h>

typedef long Int64;
typedef unsigned long UInt64;

#define Finalize(p) if (p != NULL) { (p)->Finalize(p); }

_C_IFACE_DECL (ISeqInStream)
{
    void (*Read)(ISeqInStreamPtr p, void *buf, size_t *size, lzma_io_status *status);
    /* if (input(*size) != 0 && output(*size) == 0) means end_of_stream.
       (output(*size) < input(*size)) is allowed */
    void (*Finalize)(ISeqInStreamPtr p);
    void *context;
};
#define ISeqInStream_Read(p, buf, size, status) (p)->Read(p, buf, size, status);


_C_IFACE_DECL (ISeqOutStream)
{
  size_t (*Write)(ISeqOutStreamPtr p, const void *buf, size_t size, lzma_io_status *status);
    /* Returns: result - the number of actually written bytes.
       (result < size) means error */
  void (*Finalize)(ISeqOutStreamPtr p);
  void *context;
};
#define ISeqOutStream_Write(p, buf, size, status) (p)->Write(p, buf, size, status);


_C_IFACE_DECL (IStreamCancelation)
{
    void (*Cancelation)(IStreamCancelationPtr p, bool *cancel);
    /* Returns: result. (result != SZ_OK) means break.
       Value (UInt64)(Int64)-1 for size means unknown value. */
    void (*Finalize)(IStreamCancelationPtr p);
    void *context;
};
#define CheckStreamCancel(p, cancel) if (p != NULL) { (p)->Cancelation(p, cancel); }


_C_IFACE_DECL (ICompressProgress)
{
    void (*Progress)(ICompressProgressPtr p, UInt64 inSize, UInt64 outSize);
    /* Returns: result. (result != SZ_OK) means break.
       Value (UInt64)(Int64)-1 for size means unknown value. */
    void (*Finalize)(ICompressProgressPtr p);
    void *context;
};
#define ICompressProgress_Progress(p, inSize, outSize) if (p != NULL) { (p)->Progress(p, inSize, outSize); }


#endif
