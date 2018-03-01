#ifndef __DISTANCE_WEI_H__
#define __DISTANCE_WEI_H__

#include <stdint.h>

static void distance_wei(double *restrict d, uint32_t n) {

  for (uint32_t i = 0; i < n; i++) {
    d[i*n+i] = 0.0;
  }

  for (uint32_t k = 0; k < n; k++) {
    for (uint32_t i = 0; i < n; i++) {
      for (uint32_t j = 0; j < n; j++) {
        if (d[i*n+j] > d[i*n+k] + d[k*n+j]) {
          d[i*n+j] = d[i*n+k] + d[k*n+j];
        }
      }
    }
  }

}

#endif
