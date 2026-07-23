//
//  Created by Kurlovich Vitali on 7/22/26.
//

#include "xz_stream.h"

#include <stdio.h>
#include <stdlib.h>
#include "../lzma2602/C/7zAlloc.h"
#include "../lzma2602/C/Xz.h"

// Encoder
#include "../lzma2602/C/XzEnc.h"

// Standard memory allocation wrapper provided by the LZMA SDK
static ISzAlloc g_Alloc = { SzAlloc, SzFree };

int Decode_XZ_Stream(ISeqInStream *inStream, ISeqOutStream *outStream) {
    // 1. Create decoder instance using memory allocators from 7zAlloc
    CXzDecMtHandle dec = XzDecMt_Create(&g_Alloc, &g_Alloc);
    if (!dec) {
        fprintf(stderr, "Failed to create XzDecMt instance.\n");
        return SZ_ERROR_MEM;
    }

    // 2. Initialize decoding properties
    CXzDecMtProps props;
    XzDecMtProps_Init(&props);
    
    // Set thread count (0 defaults to auto/system thread count)
    props.numThreads = 0;

    // 3. Prepare status tracking variables
    CXzStatInfo stat;
    int isMT; // Receives whether multi-threading was active during decoding

    // 4. Decode stream
    SRes res = XzDecMt_Decode(
        dec,
        &props,
        NULL,           // Optional outData size limit
        0,              // finishMode (0 = CODER_FINISH_ANY)
        outStream,      // Output stream interface
        inStream,       // Input stream interface
        &stat,          // Receives decompression stats
        &isMT,          // Multi-threading status output
        NULL            // Optional progress callback (ICompressProgress*)
    );
    
    // 5. Cleanup Swift resources
    inStream -> Finalize(inStream);
    outStream -> Finalize(outStream);

    // 6. Cleanup decoder instance
    XzDecMt_Destroy(dec);

    if (res != SZ_OK) {
        fprintf(stderr, "Decoding failed with error code: %d\n", res);
        return res;
    }

   // printf("Successfully decompressed %llu uncompressed bytes.\n", (unsigned long long)stat);
    return SZ_OK;
}

int Encode_XZ_Stream(ISeqInStream *inStream, ISeqOutStream *outStream) {
    // 1. Create encoder instance using memory allocators from 7zAlloc
    CXzEncHandle enc = XzEnc_Create(&g_Alloc, &g_Alloc);
    
    if (!enc) {
        fprintf(stderr, "Failed to create XzDecMt instance.\n");
        return SZ_ERROR_MEM;
    }
    
    // 2. Initialize encoding properties
    CXzProps props;
    XzProps_Init(&props);
    
    XzEnc_SetProps(enc, &props);
    
    // 4. Encode stream
    SRes res = Xz_Encode(outStream, inStream, &props, NULL);
    
    // 5. Cleanup Swift resources
    inStream -> Finalize(inStream);
    outStream -> Finalize(outStream);
    
    // 6. Cleanup decoder instance
    XzEnc_Destroy(enc);
    
    if (res != SZ_OK) {
        fprintf(stderr, "Encoding failed with error code: %d\n", res);
        return res;
    }

   // printf("Successfully decompressed %llu uncompressed bytes.\n", (unsigned long long)stat);
    return SZ_OK;
}
