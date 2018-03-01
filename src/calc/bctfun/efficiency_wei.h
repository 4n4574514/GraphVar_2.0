#ifndef __EFFICIENCY_WEI_H__
#define __EFFICIENCY_WEI_H__

#include <stdint.h>

#include "distance_wei.h"

static double efficiency_wei(double const * const d, double *restrict w, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) {
    for (uint32_t j = 0; j < n; j++) {
      w[i*n+j] = 1.0 / d[i*n+j];
    }
  }

  distance_wei(w, n);

  double e = 0.0;
  for (uint32_t i = 0; i < n; i++) {
    for (uint32_t j = 0; j < n; j++) {
      if (i != j && w[i*n+j] != 0) {
        e += 1.0 / w[i*n+j];
      }
    }
  }

  e /= n * (n - 1);

  return e;
}

#endif
