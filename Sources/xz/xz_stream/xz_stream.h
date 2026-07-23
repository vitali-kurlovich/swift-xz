//
//  Created by Kurlovich Vitali on 7/22/26.
//

#ifndef ZIP7_INC_XZ_ENCODE_STREAM_H
#define ZIP7_INC_XZ_ENCODE_STREAM_H

#include "../lzma2602/C/7zTypes.h"

EXTERN_C_BEGIN

int Decode_XZ_Stream(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress);

int Encode_XZ_Stream(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress);
int Encode_XZ_Stream_Level(ISeqInStream *inStream, ISeqOutStream *outStream, ICompressProgress *progress, int level);

EXTERN_C_END

#endif
