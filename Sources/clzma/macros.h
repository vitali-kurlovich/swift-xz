//
//  Created by Kurlovich Vitali on 7/24/26.
//


#ifndef CLZMA_INC_MACROS_H
#define CLZMA_INC_MACROS_H


#define _C_IFACE_CONST_QUAL const

#define _C_IFACE_DECL(a) \
  struct a ## _; \
  typedef _C_IFACE_CONST_QUAL struct a ## _ * a ## Ptr; \
  typedef struct a ## _ a; \
  struct a ## _

#endif
